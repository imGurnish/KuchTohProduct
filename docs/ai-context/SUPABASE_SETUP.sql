-- =============================================================================
-- MINDSPACE DATABASE SETUP
-- Complete SQL script for Supabase PostgreSQL with pgvector
-- Local-first architecture with cloud sync for metadata only
-- 
-- USAGE: Copy and paste this entire file into Supabase SQL Editor and run
-- =============================================================================

-- -----------------------------------------------------------------------------
-- EXTENSIONS
-- -----------------------------------------------------------------------------

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- -----------------------------------------------------------------------------
-- HELPER FUNCTION: Update timestamp trigger
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- TABLE 1: user_settings
-- PURPOSE: User preferences and external connections
-- -----------------------------------------------------------------------------

CREATE TABLE public.user_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Google Drive Integration (Optional)
    google_drive_linked BOOLEAN DEFAULT false,
    google_drive_folder_id TEXT,
    google_drive_refresh_token TEXT,
    google_drive_last_sync TIMESTAMPTZ,
    
    -- Notification Settings
    fcm_token TEXT,
    notifications_enabled BOOLEAN DEFAULT true,
    reminder_default_time TIME DEFAULT '09:00:00',
    
    -- Sync Settings
    auto_sync_enabled BOOLEAN DEFAULT true,
    sync_on_wifi_only BOOLEAN DEFAULT true,
    last_sync_at TIMESTAMPTZ,
    
    -- Processing Preferences
    auto_process_new_files BOOLEAN DEFAULT true,
    preferred_language TEXT DEFAULT 'en',
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own settings"
    ON public.user_settings FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE TRIGGER user_settings_updated_at
    BEFORE UPDATE ON public.user_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- -----------------------------------------------------------------------------
-- TABLE 2: files
-- PURPOSE: Master record for all user files with local + cloud paths
-- -----------------------------------------------------------------------------

CREATE TABLE public.files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- File Identity
    original_name TEXT NOT NULL,
    file_type TEXT NOT NULL CHECK (file_type IN ('image', 'video', 'audio', 'pdf', 'text', 'link')),
    mime_type TEXT,
    
    -- Local Storage (Primary)
    local_path TEXT NOT NULL,
    local_thumbnail_path TEXT,
    
    -- Google Drive Backup (Optional)
    google_drive_file_id TEXT,
    google_drive_path TEXT,
    
    -- Deduplication
    content_hash TEXT NOT NULL,
    
    -- File Properties
    size_bytes BIGINT DEFAULT 0,
    
    -- Sync & Versioning
    local_modified_at TIMESTAMPTZ,
    is_deleted BOOLEAN DEFAULT false,
    sync_status TEXT DEFAULT 'pending' CHECK (
        sync_status IN ('pending', 'synced', 'conflict', 'local_only')
    ),
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_files_user_id ON public.files(user_id);
CREATE INDEX idx_files_file_type ON public.files(file_type);
CREATE INDEX idx_files_content_hash ON public.files(user_id, content_hash);
CREATE INDEX idx_files_sync_status ON public.files(sync_status);
CREATE INDEX idx_files_created_at ON public.files(created_at DESC);
CREATE UNIQUE INDEX idx_files_user_hash ON public.files(user_id, content_hash) WHERE is_deleted = false;

ALTER TABLE public.files ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own files"
    ON public.files FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE TRIGGER files_updated_at
    BEFORE UPDATE ON public.files
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- -----------------------------------------------------------------------------
-- TABLE 3: file_metadata
-- PURPOSE: Extracted, AI-safe information from files
-- -----------------------------------------------------------------------------

CREATE TABLE public.file_metadata (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    file_id UUID NOT NULL UNIQUE REFERENCES public.files(id) ON DELETE CASCADE,
    
    -- Core Metadata (AI-SAFE)
    title TEXT,
    summary TEXT,
    extracted_text TEXT,
    
    -- Classification (AI-SAFE)
    tags TEXT[] DEFAULT '{}',
    entities TEXT[] DEFAULT '{}',
    
    -- Extended Metadata
    extra JSONB DEFAULT '{}'::jsonb,
    
    -- Visual Properties
    dominant_colors TEXT[],
    scene_description TEXT,
    
    -- Processing State
    processing_status TEXT DEFAULT 'pending' CHECK (
        processing_status IN ('pending', 'processing', 'completed', 'failed')
    ),
    processing_error TEXT,
    processed_at TIMESTAMPTZ,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_file_metadata_file_id ON public.file_metadata(file_id);
CREATE INDEX idx_file_metadata_tags ON public.file_metadata USING GIN(tags);
CREATE INDEX idx_file_metadata_entities ON public.file_metadata USING GIN(entities);
CREATE INDEX idx_file_metadata_status ON public.file_metadata(processing_status);
CREATE INDEX idx_file_metadata_fts ON public.file_metadata 
    USING GIN(to_tsvector('english', COALESCE(title, '') || ' ' || COALESCE(summary, '') || ' ' || COALESCE(extracted_text, '')));

ALTER TABLE public.file_metadata ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own file metadata"
    ON public.file_metadata FOR ALL
    USING (EXISTS (SELECT 1 FROM public.files WHERE files.id = file_metadata.file_id AND files.user_id = auth.uid()));

CREATE TRIGGER file_metadata_updated_at
    BEFORE UPDATE ON public.file_metadata
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- -----------------------------------------------------------------------------
-- TABLE 4: file_chunks
-- PURPOSE: Chunked content with vector embeddings for semantic search
-- -----------------------------------------------------------------------------

CREATE TABLE public.file_chunks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    file_id UUID NOT NULL REFERENCES public.files(id) ON DELETE CASCADE,
    
    chunk_index INTEGER NOT NULL,
    content TEXT NOT NULL,
    embedding vector(768),
    
    start_offset INTEGER,
    end_offset INTEGER,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT unique_file_chunk UNIQUE (file_id, chunk_index)
);

CREATE INDEX idx_file_chunks_file_id ON public.file_chunks(file_id);
CREATE INDEX idx_file_chunks_order ON public.file_chunks(file_id, chunk_index);
CREATE INDEX idx_file_chunks_embedding ON public.file_chunks USING hnsw (embedding vector_cosine_ops);

ALTER TABLE public.file_chunks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own file chunks"
    ON public.file_chunks FOR ALL
    USING (EXISTS (SELECT 1 FROM public.files WHERE files.id = file_chunks.file_id AND files.user_id = auth.uid()));

-- -----------------------------------------------------------------------------
-- TABLE 5: clusters
-- PURPOSE: AI-generated logical groupings (like smart albums)
-- -----------------------------------------------------------------------------

CREATE TABLE public.clusters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    label TEXT NOT NULL,
    description TEXT,
    cluster_type TEXT DEFAULT 'auto' CHECK (cluster_type IN ('auto', 'manual', 'smart')),
    
    cover_file_id UUID REFERENCES public.files(id) ON DELETE SET NULL,
    color TEXT,
    icon TEXT,
    
    confidence FLOAT DEFAULT 0.0 CHECK (confidence >= 0 AND confidence <= 1),
    file_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_clusters_user_id ON public.clusters(user_id);
CREATE INDEX idx_clusters_type ON public.clusters(cluster_type);
CREATE INDEX idx_clusters_label ON public.clusters(user_id, label);

ALTER TABLE public.clusters ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own clusters"
    ON public.clusters FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE TRIGGER clusters_updated_at
    BEFORE UPDATE ON public.clusters
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- -----------------------------------------------------------------------------
-- TABLE 6: cluster_files
-- PURPOSE: Links files to clusters (many-to-many)
-- -----------------------------------------------------------------------------

CREATE TABLE public.cluster_files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cluster_id UUID NOT NULL REFERENCES public.clusters(id) ON DELETE CASCADE,
    file_id UUID NOT NULL REFERENCES public.files(id) ON DELETE CASCADE,
    
    similarity_score FLOAT DEFAULT 0.0,
    is_manual BOOLEAN DEFAULT false,
    
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT unique_cluster_file UNIQUE (cluster_id, file_id)
);

CREATE INDEX idx_cluster_files_cluster ON public.cluster_files(cluster_id);
CREATE INDEX idx_cluster_files_file ON public.cluster_files(file_id);

ALTER TABLE public.cluster_files ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own cluster assignments"
    ON public.cluster_files FOR ALL
    USING (EXISTS (SELECT 1 FROM public.clusters WHERE clusters.id = cluster_files.cluster_id AND clusters.user_id = auth.uid()));

-- Cluster file count trigger
CREATE OR REPLACE FUNCTION update_cluster_file_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.clusters SET file_count = file_count + 1 WHERE id = NEW.cluster_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.clusters SET file_count = file_count - 1 WHERE id = OLD.cluster_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cluster_files_count
    AFTER INSERT OR DELETE ON public.cluster_files
    FOR EACH ROW EXECUTE FUNCTION update_cluster_file_count();

-- -----------------------------------------------------------------------------
-- TABLE 7: chat_sessions
-- PURPOSE: Container for chat conversations
-- -----------------------------------------------------------------------------

CREATE TABLE public.chat_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    title TEXT DEFAULT 'New Chat',
    search_mode TEXT DEFAULT 'hybrid' CHECK (search_mode IN ('text', 'semantic', 'hybrid')),
    context_scope TEXT DEFAULT 'full' CHECK (context_scope IN ('full', 'session_only', 'selected_files')),
    
    triggered_by_reminder_id UUID,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_chat_sessions_user ON public.chat_sessions(user_id);
CREATE INDEX idx_chat_sessions_recent ON public.chat_sessions(updated_at DESC);

ALTER TABLE public.chat_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own chat sessions"
    ON public.chat_sessions FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE TRIGGER chat_sessions_updated_at
    BEFORE UPDATE ON public.chat_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- -----------------------------------------------------------------------------
-- TABLE 8: chat_messages
-- PURPOSE: Individual messages within chat sessions
-- -----------------------------------------------------------------------------

CREATE TABLE public.chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES public.chat_sessions(id) ON DELETE CASCADE,
    
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    
    inline_file_ids UUID[] DEFAULT '{}',
    
    tokens_used INTEGER,
    model_used TEXT DEFAULT 'gemini-1.5-flash',
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_chat_messages_session ON public.chat_messages(session_id);
CREATE INDEX idx_chat_messages_order ON public.chat_messages(session_id, created_at);

ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own chat messages"
    ON public.chat_messages FOR ALL
    USING (EXISTS (SELECT 1 FROM public.chat_sessions WHERE chat_sessions.id = chat_messages.session_id AND chat_sessions.user_id = auth.uid()));

-- -----------------------------------------------------------------------------
-- TABLE 9: chat_sources
-- PURPOSE: Tracks which files were used to generate AI responses
-- -----------------------------------------------------------------------------

CREATE TABLE public.chat_sources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    message_id UUID NOT NULL REFERENCES public.chat_messages(id) ON DELETE CASCADE,
    file_id UUID NOT NULL REFERENCES public.files(id) ON DELETE CASCADE,
    
    chunk_ids UUID[],
    relevance_score FLOAT,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_chat_sources_message ON public.chat_sources(message_id);
CREATE INDEX idx_chat_sources_file ON public.chat_sources(file_id);

ALTER TABLE public.chat_sources ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own chat sources"
    ON public.chat_sources FOR ALL
    USING (EXISTS (
        SELECT 1 FROM public.chat_messages 
        JOIN public.chat_sessions ON chat_sessions.id = chat_messages.session_id
        WHERE chat_messages.id = chat_sources.message_id AND chat_sessions.user_id = auth.uid()
    ));

-- -----------------------------------------------------------------------------
-- TABLE 10: reminders
-- PURPOSE: User-scheduled reminders with topic context
-- -----------------------------------------------------------------------------

CREATE TABLE public.reminders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    title TEXT NOT NULL,
    topic TEXT NOT NULL,
    user_message TEXT,
    
    scheduled_at TIMESTAMPTZ NOT NULL,
    recurrence TEXT CHECK (recurrence IN ('none', 'daily', 'weekly', 'monthly')) DEFAULT 'none',
    
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'dismissed', 'snoozed', 'cancelled')),
    sent_at TIMESTAMPTZ,
    
    triggered_chat_session_id UUID REFERENCES public.chat_sessions(id),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_reminders_user ON public.reminders(user_id);
CREATE INDEX idx_reminders_scheduled ON public.reminders(scheduled_at) WHERE status = 'pending';
CREATE INDEX idx_reminders_status ON public.reminders(status);

ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own reminders"
    ON public.reminders FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE TRIGGER reminders_updated_at
    BEFORE UPDATE ON public.reminders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- -----------------------------------------------------------------------------
-- TABLE 11: reminder_files
-- PURPOSE: Files relevant to a reminder's topic
-- -----------------------------------------------------------------------------

CREATE TABLE public.reminder_files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reminder_id UUID NOT NULL REFERENCES public.reminders(id) ON DELETE CASCADE,
    file_id UUID NOT NULL REFERENCES public.files(id) ON DELETE CASCADE,
    
    relevance_score FLOAT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT unique_reminder_file UNIQUE (reminder_id, file_id)
);

CREATE INDEX idx_reminder_files_reminder ON public.reminder_files(reminder_id);
CREATE INDEX idx_reminder_files_file ON public.reminder_files(file_id);

ALTER TABLE public.reminder_files ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own reminder files"
    ON public.reminder_files FOR ALL
    USING (EXISTS (SELECT 1 FROM public.reminders WHERE reminders.id = reminder_files.reminder_id AND reminders.user_id = auth.uid()));

-- -----------------------------------------------------------------------------
-- TABLE 12: processing_jobs
-- PURPOSE: Track file processing stages and status
-- -----------------------------------------------------------------------------

CREATE TABLE public.processing_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    file_id UUID NOT NULL REFERENCES public.files(id) ON DELETE CASCADE,
    
    stage TEXT NOT NULL CHECK (stage IN ('uploading', 'extracting', 'embedding', 'chunking', 'tagging', 'clustering', 'backup')),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
    
    progress INTEGER DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    
    worker_id TEXT,
    worker_type TEXT,
    
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_processing_jobs_file ON public.processing_jobs(file_id);
CREATE INDEX idx_processing_jobs_status ON public.processing_jobs(status);
CREATE INDEX idx_processing_jobs_pending ON public.processing_jobs(status, created_at) WHERE status = 'pending';
CREATE INDEX idx_processing_jobs_worker ON public.processing_jobs(worker_type, status);

ALTER TABLE public.processing_jobs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own processing jobs"
    ON public.processing_jobs FOR ALL
    USING (EXISTS (SELECT 1 FROM public.files WHERE files.id = processing_jobs.file_id AND files.user_id = auth.uid()));

CREATE TRIGGER processing_jobs_updated_at
    BEFORE UPDATE ON public.processing_jobs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- -----------------------------------------------------------------------------
-- FUNCTION: semantic_search
-- PURPOSE: Find similar content using vector similarity
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION semantic_search(
    query_embedding vector(768),
    match_threshold FLOAT DEFAULT 0.7,
    match_count INT DEFAULT 10,
    p_user_id UUID DEFAULT auth.uid()
)
RETURNS TABLE (
    chunk_id UUID,
    file_id UUID,
    file_name TEXT,
    local_path TEXT,
    content TEXT,
    similarity FLOAT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        fc.id AS chunk_id,
        fc.file_id,
        f.original_name AS file_name,
        f.local_path,
        fc.content,
        1 - (fc.embedding <=> query_embedding) AS similarity
    FROM public.file_chunks fc
    JOIN public.files f ON f.id = fc.file_id
    WHERE f.user_id = p_user_id
    AND f.is_deleted = false
    AND 1 - (fc.embedding <=> query_embedding) > match_threshold
    ORDER BY fc.embedding <=> query_embedding
    LIMIT match_count;
END;
$$;

-- -----------------------------------------------------------------------------
-- FUNCTION: hybrid_search
-- PURPOSE: Combine text + semantic search with weighted scoring
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION hybrid_search(
    query_text TEXT,
    query_embedding vector(768),
    text_weight FLOAT DEFAULT 0.3,
    semantic_weight FLOAT DEFAULT 0.7,
    match_count INT DEFAULT 10,
    p_user_id UUID DEFAULT auth.uid()
)
RETURNS TABLE (
    file_id UUID,
    file_name TEXT,
    local_path TEXT,
    chunk_content TEXT,
    text_score FLOAT,
    semantic_score FLOAT,
    combined_score FLOAT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    WITH text_results AS (
        SELECT 
            fc.file_id,
            fc.content,
            ts_rank(to_tsvector('english', fc.content), plainto_tsquery('english', query_text)) AS txt_score
        FROM public.file_chunks fc
        JOIN public.files f ON f.id = fc.file_id
        WHERE f.user_id = p_user_id AND f.is_deleted = false
        AND to_tsvector('english', fc.content) @@ plainto_tsquery('english', query_text)
    ),
    semantic_results AS (
        SELECT 
            fc.file_id,
            fc.content,
            1 - (fc.embedding <=> query_embedding) AS sem_score
        FROM public.file_chunks fc
        JOIN public.files f ON f.id = fc.file_id
        WHERE f.user_id = p_user_id AND f.is_deleted = false
    ),
    combined AS (
        SELECT 
            COALESCE(t.file_id, s.file_id) AS file_id,
            COALESCE(t.content, s.content) AS content,
            COALESCE(t.txt_score, 0) AS txt_score,
            COALESCE(s.sem_score, 0) AS sem_score
        FROM text_results t
        FULL OUTER JOIN semantic_results s ON t.file_id = s.file_id AND t.content = s.content
    )
    SELECT 
        c.file_id,
        f.original_name AS file_name,
        f.local_path,
        c.content AS chunk_content,
        c.txt_score AS text_score,
        c.sem_score AS semantic_score,
        (c.txt_score * text_weight + c.sem_score * semantic_weight) AS combined_score
    FROM combined c
    JOIN public.files f ON f.id = c.file_id
    WHERE (c.txt_score > 0 OR c.sem_score > 0.5)
    ORDER BY (c.txt_score * text_weight + c.sem_score * semantic_weight) DESC
    LIMIT match_count;
END;
$$;

-- -----------------------------------------------------------------------------
-- FUNCTION: get_chat_context
-- PURPOSE: Retrieve relevant context for AI chat responses
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_chat_context(
    query_embedding vector(768),
    query_text TEXT DEFAULT '',
    max_chunks INT DEFAULT 5,
    max_tokens INT DEFAULT 4000,
    p_user_id UUID DEFAULT auth.uid()
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result JSONB := '[]'::jsonb;
    total_chars INT := 0;
    char_limit INT := max_tokens * 4;
    chunk_record RECORD;
BEGIN
    FOR chunk_record IN 
        SELECT 
            f.id AS file_id,
            f.original_name AS file_name,
            f.local_path,
            f.file_type,
            fm.title,
            fm.summary,
            fm.tags,
            fc.content AS chunk_content,
            1 - (fc.embedding <=> query_embedding) AS similarity
        FROM public.file_chunks fc
        JOIN public.files f ON f.id = fc.file_id
        LEFT JOIN public.file_metadata fm ON fm.file_id = f.id
        WHERE f.user_id = p_user_id AND f.is_deleted = false
        ORDER BY fc.embedding <=> query_embedding
        LIMIT max_chunks * 2
    LOOP
        IF total_chars + LENGTH(chunk_record.chunk_content) > char_limit THEN
            EXIT;
        END IF;
        
        result := result || jsonb_build_object(
            'file_id', chunk_record.file_id,
            'file_name', chunk_record.file_name,
            'local_path', chunk_record.local_path,
            'file_type', chunk_record.file_type,
            'title', chunk_record.title,
            'summary', chunk_record.summary,
            'tags', chunk_record.tags,
            'content', chunk_record.chunk_content,
            'similarity', chunk_record.similarity
        );
        
        total_chars := total_chars + LENGTH(chunk_record.chunk_content);
        
        IF jsonb_array_length(result) >= max_chunks THEN
            EXIT;
        END IF;
    END LOOP;
    
    RETURN result;
END;
$$;

-- -----------------------------------------------------------------------------
-- FUNCTION: check_file_exists
-- PURPOSE: Deduplication check by content hash
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION check_file_exists(
    p_content_hash TEXT,
    p_user_id UUID DEFAULT auth.uid()
)
RETURNS TABLE (
    exists_already BOOLEAN,
    existing_file_id UUID,
    existing_local_path TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        true AS exists_already,
        f.id AS existing_file_id,
        f.local_path AS existing_local_path
    FROM public.files f
    WHERE f.user_id = p_user_id
    AND f.content_hash = p_content_hash
    AND f.is_deleted = false
    LIMIT 1;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, NULL::UUID, NULL::TEXT;
    END IF;
END;
$$;

-- -----------------------------------------------------------------------------
-- FUNCTION: get_reminder_context
-- PURPOSE: Find relevant files for a reminder topic
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_reminder_context(
    topic_embedding vector(768),
    topic_text TEXT,
    max_files INT DEFAULT 5,
    p_user_id UUID DEFAULT auth.uid()
)
RETURNS TABLE (
    file_id UUID,
    file_name TEXT,
    local_path TEXT,
    file_type TEXT,
    relevance_score FLOAT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (f.id)
        f.id AS file_id,
        f.original_name AS file_name,
        f.local_path,
        f.file_type,
        1 - (fc.embedding <=> topic_embedding) AS relevance_score
    FROM public.file_chunks fc
    JOIN public.files f ON f.id = fc.file_id
    WHERE f.user_id = p_user_id AND f.is_deleted = false
    ORDER BY f.id, fc.embedding <=> topic_embedding
    LIMIT max_files;
END;
$$;

-- -----------------------------------------------------------------------------
-- COMPLETE!
-- All 12 tables, indexes, RLS policies, triggers, and functions created.
-- -----------------------------------------------------------------------------
