import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/file_item.dart';
import '../../domain/repositories/files_repository.dart';
import '../datasources/files_local_data_source.dart';

/// Files Repository Implementation
///
/// Implements FilesRepository using local data source.
class FilesRepositoryImpl implements FilesRepository {
  final FilesLocalDataSource _dataSource;

  FilesRepositoryImpl({required FilesLocalDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<bool> hasPermission() => _dataSource.hasPermission();

  @override
  Future<bool> requestPermission() => _dataSource.requestPermission();

  @override
  Future<bool> isPermanentlyDenied() => _dataSource.isPermanentlyDenied();

  @override
  Future<bool> openSettings() => _dataSource.openSettings();

  @override
  ResultFuture<List<FileItem>> getFilesByCategory(FileType type) async {
    try {
      final files = await _dataSource.getFilesByCategory(type);
      return Right(files);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<FileItem>> getAllFiles() async {
    try {
      final files = await _dataSource.getAllFiles();
      return Right(files);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<Map<FileType, int>> getFileCounts() async {
    try {
      final counts = await _dataSource.getFileCounts();
      return Right(counts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid deleteFile(String id) async {
    try {
      await _dataSource.deleteFile(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid forceRefresh() async {
    try {
      await _dataSource.forceRefresh();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
