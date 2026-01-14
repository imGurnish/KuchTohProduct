import 'package:equatable/equatable.dart';

/// User Entity
///
/// Core domain representation of a user.
class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    this.createdAt,
    this.lastSignInAt,
  });

  /// Empty user for unauthenticated state
  static const empty = User(id: '', email: '');

  /// Check if user is empty/unauthenticated
  bool get isEmpty => this == empty;
  bool get isNotEmpty => !isEmpty;

  /// Display name or email prefix
  String get displayLabel => displayName ?? email.split('@').first;

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    emailVerified,
    createdAt,
    lastSignInAt,
  ];
}
