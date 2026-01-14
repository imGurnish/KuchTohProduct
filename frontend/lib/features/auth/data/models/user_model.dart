import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user.dart' as domain;

/// User Model
///
/// Data model that extends the domain User entity.
/// Handles conversion from Supabase User to domain User.
class UserModel extends domain.User {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.emailVerified,
    super.createdAt,
  });

  /// Create UserModel from Supabase User
  factory UserModel.fromSupabaseUser(User supabaseUser) {
    return UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      displayName: supabaseUser.userMetadata?['display_name'] as String?,
      photoUrl: supabaseUser.userMetadata?['avatar_url'] as String?,
      emailVerified: supabaseUser.emailConfirmedAt != null,
      createdAt: DateTime.tryParse(supabaseUser.createdAt),
    );
  }

  /// Create empty UserModel
  static const UserModel empty = UserModel(id: '', email: '');
}
