# AI Context Documentation

Comprehensive documentation for the Mindspace personal knowledge management system.

---

## 📚 Documentation Index

| Document | Purpose |
|----------|---------|
| [PROJECT_OVERVIEW.md](./PROJECT_OVERVIEW.md) | Architecture, tech stack, data flow, features |
| [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) | 12 Supabase tables with SQL, RLS policies |
| [AI_INTEGRATION.md](./AI_INTEGRATION.md) | AI rules, prompts, privacy constraints |
| [DEVOPS.md](./DEVOPS.md) | Kubernetes infrastructure, pods, scaling |
| [SUPABASE_SETUP.sql](./SUPABASE_SETUP.sql) | Ready-to-execute SQL script |

---

## ⚡ Quick Reference

### Core Architecture
```
Flutter App (Local-First)
    ↓ Upload for processing
Go Backend (Kubernetes)
    ↓ Extract, embed, tag, cluster → DISCARD FILE
Supabase (Metadata only)
    ↓ Sync
Local SQLite (Primary storage)
```

### Critical Privacy Rule
> **AI NEVER sees original files.** Only extracted text, summaries, tags, and embeddings.  
> **Files stay on device.** Backend discards files after processing.

### Database Tables (12 total)
1. `user_settings` - Preferences, Google Drive link, FCM token
2. `files` - Registry with local_path, google_drive_id, content_hash
3. `file_metadata` - AI-safe extracted data
4. `file_chunks` - Vector embeddings (768-dim)
5. `clusters` - Auto-generated tag groups (albums)
6. `cluster_files` - Cluster membership
7. `chat_sessions` - Conversation containers
8. `chat_messages` - Messages with inline_file_ids
9. `chat_sources` - File citations
10. `reminders` - Scheduled notifications
11. `reminder_files` - Files attached to reminders
12. `processing_jobs` - Background task queue

### Key Features
| Feature | Description |
|---------|-------------|
| **Local-First** | Files never leave device (except temporary processing) |
| **Google Drive Backup** | Optional, user's own account |
| **Smart Albums** | Auto-clustering into tag groups |
| **AI Chat** | Gemini-powered with full device context |
| **Inline Files** | Raw files displayed in chat responses |
| **Reminders** | Scheduled notifications with AI context |
| **Deduplication** | SHA-256 hash prevents duplicates |

---

## 🤖 Guidelines for AI Assistants

1. **Read [AI_INTEGRATION.md](./AI_INTEGRATION.md)** before AI-related changes
2. **Never send raw files** to external AI services
3. **Use provided search functions** - `semantic_search()`, `hybrid_search()`
4. **Return file_ids** for frontend to load locally
5. **Respect RLS** - All queries respect Row Level Security

---

## 🚀 Setup Steps

1. **Database**: Copy `SUPABASE_SETUP.sql` to Supabase SQL Editor and execute
2. **Backend**: Deploy Go API + processing pods to Kubernetes
3. **Frontend**: Configure Flutter app with Supabase credentials
4. **Optional**: Set up Google Drive OAuth for backup feature

---

*Last updated: January 2026*