import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/file_item.dart';
import '../../domain/repositories/files_repository.dart';

part 'files_event.dart';
part 'files_state.dart';

/// Files BLoC
///
/// Manages file browsing state with category filtering.
class FilesBloc extends Bloc<FilesEvent, FilesState> {
  final FilesRepository _filesRepository;

  FilesBloc({required FilesRepository filesRepository})
    : _filesRepository = filesRepository,
      super(const FilesInitial()) {
    on<LoadFiles>(_onLoadFiles);
    on<ChangeCategory>(_onChangeCategory);
    on<DeleteFile>(_onDeleteFile);
    on<RefreshFiles>(_onRefreshFiles);
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
        currentState.copyWith(files: files, selectedCategory: event.category),
      ),
    );
  }

  Future<void> _onDeleteFile(DeleteFile event, Emitter<FilesState> emit) async {
    final currentState = state;
    if (currentState is! FilesLoaded) return;

    final result = await _filesRepository.deleteFile(event.fileId);

    result.fold((failure) => emit(FilesError(failure.message)), (_) {
      // Reload files after deletion
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
      add(const LoadFiles());
    }
  }
}
