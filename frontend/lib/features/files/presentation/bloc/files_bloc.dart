import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/file_item.dart';
import '../../domain/repositories/files_repository.dart';

part 'files_event.dart';
part 'files_state.dart';

/// Files BLoC
///
/// Manages file browsing state with category filtering, search, and permissions.
class FilesBloc extends Bloc<FilesEvent, FilesState> {
  final FilesRepository _filesRepository;

  FilesBloc({required FilesRepository filesRepository})
    : _filesRepository = filesRepository,
      super(const FilesInitial()) {
    on<CheckPermission>(_onCheckPermission);
    on<RequestPermission>(_onRequestPermission);
    on<OpenSettings>(_onOpenSettings);
    on<LoadFiles>(_onLoadFiles);
    on<ChangeCategory>(_onChangeCategory);
    on<SearchFiles>(_onSearchFiles);
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
      add(const LoadFiles());
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
      add(const LoadFiles());
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

  Future<void> _onLoadFiles(LoadFiles event, Emitter<FilesState> emit) async {
    emit(const FilesLoading());

    final category = event.category ?? FileType.image;
    final countsResult = await _filesRepository.getFileCounts();
    final filesResult = await _filesRepository.getFilesByCategory(category);

    countsResult.fold((failure) => emit(FilesError(failure.message)), (counts) {
      filesResult.fold(
        (failure) => emit(FilesError(failure.message)),
        (files) => emit(
          FilesLoaded(
            files: files,
            allFiles: files,
            selectedCategory: category,
            fileCounts: counts,
          ),
        ),
      );
    });
  }

  Future<void> _onChangeCategory(
    ChangeCategory event,
    Emitter<FilesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FilesLoaded) return;

    emit(const FilesLoading());

    final filesResult = await _filesRepository.getFilesByCategory(
      event.category,
    );

    filesResult.fold(
      (failure) => emit(FilesError(failure.message)),
      (files) => emit(
        FilesLoaded(
          files: files,
          allFiles: files,
          selectedCategory: event.category,
          fileCounts: currentState.fileCounts,
          searchQuery: '',
          isSearching: false,
        ),
      ),
    );
  }

  void _onSearchFiles(SearchFiles event, Emitter<FilesState> emit) {
    final currentState = state;
    if (currentState is! FilesLoaded) return;

    final query = event.query.toLowerCase().trim();

    if (query.isEmpty) {
      emit(
        currentState.copyWith(
          files: currentState.allFiles,
          searchQuery: '',
          isSearching: false,
        ),
      );
      return;
    }

    // Filter files by name and extension
    final filteredFiles = currentState.allFiles.where((file) {
      final name = file.name.toLowerCase();
      final extension = file.extension.toLowerCase();
      return name.contains(query) || extension.contains(query);
    }).toList();

    emit(
      currentState.copyWith(
        files: filteredFiles,
        searchQuery: query,
        isSearching: true,
      ),
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<FilesState> emit) {
    final currentState = state;
    if (currentState is! FilesLoaded) return;

    emit(
      currentState.copyWith(
        files: currentState.allFiles,
        searchQuery: '',
        isSearching: false,
      ),
    );
  }

  Future<void> _onDeleteFile(DeleteFile event, Emitter<FilesState> emit) async {
    final currentState = state;
    if (currentState is! FilesLoaded) return;

    final result = await _filesRepository.deleteFile(event.fileId);

    result.fold((failure) => emit(FilesError(failure.message)), (_) {
      add(ChangeCategory(currentState.selectedCategory));
    });
  }

  Future<void> _onRefreshFiles(
    RefreshFiles event,
    Emitter<FilesState> emit,
  ) async {
    final currentState = state;
    if (currentState is FilesLoaded) {
      add(ChangeCategory(currentState.selectedCategory));
    } else {
      add(const CheckPermission());
    }
  }
}
