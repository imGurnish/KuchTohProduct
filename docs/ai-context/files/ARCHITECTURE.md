# Files Architecture

## Overview

The files system follows **Clean Architecture** principles with three distinct layers:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │  FilesBloc  │  │FilesScreen  │  │   Widgets           │ │
│  │  (State)    │  │(Home/Files) │  │  (Cards, Sheets)    │ │
│  └──────┬──────┘  └─────────────┘  └─────────────────────┘ │
└─────────┼───────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌─────────────────────┐  ┌─────────────────────────────┐  │
│  │  FilesRepository    │  │    FileItem Entity          │  │
│  │  (Abstract)         │  │    FileType Enum            │  │
│  └──────────┬──────────┘  └─────────────────────────────┘  │
└─────────────┼───────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌─────────────────────┐  ┌─────────────────────────────┐  │
│  │ FilesRepositoryImpl │  │ FilesLocalDataSource        │  │
│  │ (Implementation)    │──│ (Caching + Access)          │  │
│  └─────────────────────┘  └─────────────────────────────┘  │
│                           ┌─────────────────────────────┐  │
│                           │  FileScannerService         │  │
│                           │  (Platform File Discovery)  │  │
│                           └─────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### Load Home View

```mermaid
sequenceDiagram
    participant UI as FilesScreen
    participant Bloc as FilesBloc
    participant Repo as FilesRepository
    participant DS as LocalDataSource
    participant Scanner as FileScannerService

    UI->>Bloc: CheckPermission
    Bloc->>Repo: hasPermission()
    Repo->>DS: hasPermission()
    DS->>Scanner: hasPermission()
    Scanner-->>DS: true/false
    
    alt Permission Granted
        Bloc->>Bloc: emit(LoadInitialData)
        Bloc->>Repo: getFileCounts()
        Repo->>DS: getFileCounts()
        DS-->>Repo: Map<FileType, int>
        Repo-->>Bloc: Right(counts)
        Bloc->>Bloc: emit(FilesReady(home))
    else Permission Denied
        Bloc->>Bloc: emit(FilesPermissionRequired)
    end
```

### Open Category Flow

```mermaid
sequenceDiagram
    participant UI as FilesScreen
    participant Bloc as FilesBloc
    participant DS as LocalDataSource
    participant Cache as SharedPreferences

    UI->>Bloc: OpenCategory(FileType.image)
    Bloc->>Bloc: emit(FilesLoading)
    Bloc->>DS: getFilesByCategory(image)
    
    DS->>DS: Check memory cache
    alt Memory Cache Hit
        DS-->>Bloc: cached files
    else Check Persistent Cache
        DS->>Cache: getString("files_cache_image")
        alt Cache Valid (< 24h old)
            Cache-->>DS: JSON files
            DS-->>Bloc: parsed files
        else Cache Invalid
            DS->>DS: scanFilesByType(image)
            DS->>Cache: save to cache
            DS-->>Bloc: scanned files
        end
    end
    
    Bloc->>Bloc: emit(FilesReady(category))
```

### Search Flow

```mermaid
flowchart TD
    A[User Types Query] --> B[SearchAllFiles event]
    B --> C{All Files Cached?}
    C -->|No| D[Load All Files]
    D --> E[Cache in _allFilesCache]
    C -->|Yes| F[Filter by name/extension]
    E --> F
    F --> G[emit FilesReady with search mode]
```

## State Machine

```
                    ┌─────────────┐
                    │FilesInitial │
                    └──────┬──────┘
                           │ CheckPermission
                           ▼
                    ┌──────────────────┐
              ┌─────│FilesCheckingPerm │─────┐
              │     └──────────────────┘     │
              ▼                              ▼
    ┌─────────────────┐          ┌──────────────────────┐
    │  FilesLoading   │          │FilesPermissionRequired│
    └────────┬────────┘          └──────────────────────┘
             │
             ▼
    ┌─────────────────────────────────────┐
    │            FilesReady               │
    │  ┌─────────────────────────────┐   │
    │  │ viewMode: home | category   │   │
    │  │           | search          │   │
    │  ├─────────────────────────────┤   │
    │  │ fileCounts: Map<FileType,int>│  │
    │  │ files: List<FileItem>        │  │
    │  │ selectedCategory: FileType?  │  │
    │  │ searchQuery: String          │  │
    │  └─────────────────────────────┘   │
    └─────────────────────────────────────┘
```

## View Modes

| Mode | Description | UI |
|------|-------------|-----|
| `home` | Default view | Category cards grid |
| `category` | Files in a category | File cards grid |
| `search` | Search results | Filtered files grid |

## Caching Strategy

```
┌─────────────────────────────────────────────┐
│              MEMORY CACHE                    │
│  Map<FileType, List<FileItemModel>>         │
│  - Fastest access                            │
│  - Lost on app restart                       │
└─────────────────────────────────────────────┘
                    ↓ fallback
┌─────────────────────────────────────────────┐
│           PERSISTENT CACHE                   │
│  SharedPreferences JSON                      │
│  - 24-hour TTL                               │
│  - Survives app restart                      │
└─────────────────────────────────────────────┘
                    ↓ fallback
┌─────────────────────────────────────────────┐
│           FILE SYSTEM SCAN                   │
│  FileScannerService                          │
│  - Full directory traversal                  │
│  - Slowest but most current                  │
└─────────────────────────────────────────────┘
```

## Dependency Injection

```dart
// Services
sl.registerLazySingleton<FileScannerService>(
  () => FileScannerService(),
);

// Data Sources
sl.registerLazySingleton<FilesLocalDataSource>(
  () => FilesLocalDataSourceImpl(scanner: sl<FileScannerService>()),
);

// Repositories
sl.registerLazySingleton<FilesRepository>(
  () => FilesRepositoryImpl(dataSource: sl<FilesLocalDataSource>()),
);

// BLoC
sl.registerFactory<FilesBloc>(
  () => FilesBloc(filesRepository: sl<FilesRepository>()),
);
```
