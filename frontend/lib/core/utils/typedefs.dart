import 'package:fpdart/fpdart.dart';
import '../error/failures.dart';

/// Type alias for Either type with Failure on left (error) and T on right (success)
/// Used for repository and use case return types
typedef ResultFuture<T> = Future<Either<Failure, T>>;

/// Type alias for synchronous Either result
typedef Result<T> = Either<Failure, T>;

/// Type alias for void results (success with no return value)
typedef ResultVoid = ResultFuture<void>;

/// Type alias for JSON map
typedef DataMap = Map<String, dynamic>;
