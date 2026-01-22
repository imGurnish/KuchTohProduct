import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/file_item.dart';
import '../../domain/repositories/files_repository.dart';

part 'files_event.dart';
part 'files_state.dart';

/// Files BLoC
///
/// Manages file browsing with home/category views and global search.
class FilesBloc extends Bloc<FilesEvent, FilesState> {
  final FilesRepository _filesRepository;

  // Cache all files for search
  List<FileItem> _allFilesCache = [];

  FilesBloc({required FilesRepository filesRepository})
    : _filesRepository = filesRepository,
      super(const FilesInitial()) {
    on<CheckPermission>(_onCheckPermission);
    on<RequestPermission>(_onRequestPermission);
    on<OpenSettings>(_onOpenSettings);
    on<LoadInitialData>(_onLoadInitialData);
    on<OpenCategory>(_onOpenCategory);
    on<GoBackToHome>(_onGoBackToHome);
    on<SearchAllFiles>(_onSearchAllFiles);
    on<ClearSearch>(_onClearSearch);
    on<DeleteFile>(_onDeleteFile);
    on<RefreshFiles>(_onRefreshFiles);
  }

  Future<void> _onCheckPermission(
    CheckPermission event,
    Emitter<FilesState> emit,
  ) async {
    emit(const FilesCheckingPermission());

    final hasPermission = await _filesRepository.hasPermission();
    if (hasPermission) {
      add(const LoadInitialData());
    } else {
      final isPermanentlyDenied = await _filesRepository.isPermanentlyDenied();
      emit(
        FilesPermissionRequired(
          status: isPermanentlyDenied
              ? PermissionStatus.permanentlyDenied
              : PermissionStatus.denied,
        ),
      );
    }
  }

  Future<void> _onRequestPermission(
    RequestPermission event,
    Emitter<FilesState> emit,
  ) async {
    emit(const FilesCheckingPermission());

    final granted = await _filesRepository.requestPermission();
    if (granted) {
      add(const LoadInitialData());
    } else {
      final isPermanentlyDenied = await _filesRepository.isPermanentlyDenied();
      emit(
        FilesPermissionRequired(
          status: isPermanentlyDenied
              ? PermissionStatus.permanentlyDenied
              : PermissionStatus.denied,
        ),
      );
    }
  }

  Future<void> _onOpenSettings(
    OpenSettings event,
    Emitter<FilesState> emit,
  ) async {
    await _filesRepository.openSettings();
    add(const CheckPermission());
  }

  Future<void> _onLoadInitialData(
    LoadInitialData event,
    Emitter<FilesState> emit,
  ) async {
    emit(const FilesLoading());

    final countsResult = await _filesRepository.getFileCounts();

    countsResult.fold(
      (failure) => emit(FilesError(failure.message)),
      (counts) =>
          emit(FilesReady(viewMode: FilesViewMode.home, fileCounts: counts)),
    );
  }

  Future<void> _onOpenCategory(
    OpenCategory event,
    Emitter<FilesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FilesReady) return;

    emit(const FilesLoading());

    final filesResult = await _filesRepository.getFilesByCategory(
      event.category,
    );

    filesResult.fold(
      (failure) => emit(FilesError(failure.message)),
      (files) => emit(
        FilesReady(
          viewMode: FilesViewMode.category,
          fileCounts: currentState.fileCounts,
          selectedCategory: event.category,
          files: files,
        ),
      ),
    );
  }

  void _onGoBackToHome(GoBackToHome event, Emitter<FilesState> emit) {
    final currentState = state;
    if (currentState is! FilesReady) return;

    emit(
      FilesReady(
        viewMode: FilesViewMode.home,
        fileCounts: currentState.fileCounts,
      ),
    );
  }

  Future<void> _onSearchAllFiles(
    SearchAllFiles event,
    Emitter<FilesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FilesReady) return;

    final query = event.query.toLowerCase().trim();

    if (query.isEmpty) {
      emit(
        currentState.copyWith(
          viewMode: FilesViewMode.home,
          files: [],
          searchQuery: '',
        ),
      );
      return;
    }

    // Load all files if cache is empty
    if (_allFilesCache.isEmpty) {
      final allFilesResult = await _filesRepository.getAllFiles();
      allFilesResult.fold((failure) => null, (files) => _allFilesCache = files);
    }

    // Filter all files by name and extension
    final filteredFiles = _allFilesCache.where((file) {
      final name = file.name.toLowerCase();
      final extension = file.extension.toLowerCase();
      return name.contains(query) || extension.contains(query);
    }).toList();

    emit(
      currentState.copyWith(
        viewMode: FilesViewMode.search,
        files: filteredFiles,
        searchQuery: query,
      ),
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<FilesState> emit) {
    final currentState = state;
    if (currentState is! FilesReady) return;

    emit(
      FilesReady(
        viewMode: FilesViewMode.home,
        fileCounts: currentState.fileCounts,
      ),
    );
  }

  Future<void> _onDeleteFile(DeleteFile event, Emitter<FilesState> emit) async {
    final currentState = state;
    if (currentState is! FilesReady) return;

    final result = await _filesRepository.deleteFile(event.fileId);

    result.fold((failure) => emit(FilesError(failure.message)), (_) {
      _allFilesCache = []; // Clear cache
      if (currentState.selectedCategory != null) {
        add(OpenCategory(currentState.selectedCategory!));
      } else {
        add(const LoadInitialData());
      }
    });
  }

  Future<void> _onRefreshFiles(
    RefreshFiles event,
    Emitter<FilesState> emit,
  ) async {
    final currentState = state;

    emit(const FilesLoading());
    await _filesRepository.forceRefresh();
    _allFilesCache = [];

    if (currentState is FilesReady && currentState.selectedCategory != null) {
      add(OpenCategory(currentState.selectedCategory!));
    } else {
      add(const LoadInitialData());
    }
  }
}
