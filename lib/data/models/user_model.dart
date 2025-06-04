import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    required super.createdAt,
    super.lastLoginAt,
  });

  // Convert from database Map
  factory UserModel.fromDatabase(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastLoginAt: map['last_login_at'] != null 
          ? DateTime.parse(map['last_login_at'] as String)
          : null,
    );
  }

  // Convert to database Map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  // Create user for database insertion (with password hash)
  Map<String, dynamic> toDatabaseWithPassword(String passwordHash) {
    final dbMap = toDatabase();
    dbMap['password_hash'] = passwordHash;
    return dbMap;
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
    );
  }
}
