import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../datasources/local/database_helper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DatabaseHelper _databaseHelper;
  static const String _userSessionKey = 'user_session';

  AuthRepositoryImpl(this._databaseHelper);

  @override
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userSessionKey);

    if (userJson == null) return null;

    final userMap = jsonDecode(userJson) as Map<String, dynamic>;
    return UserModel.fromDatabase(userMap);
  }

  @override
  Future<User> login(String email, String password) async {
    final db = await _databaseHelper.database;

    // Buscar usuario por email
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (users.isEmpty) {
      throw Exception('Usuario no encontrado');
    }

    final userData = users.first;

    final passwordHash = userData['password_hash'] as String?;
    if (passwordHash == null) {
      throw Exception('Contraseña no configurada para este usuario');
    }
    // con crypto package, you would do something like:
    final inputPasswordHash = _hashPassword(password);

    // Usar comparación segura
    if (!_secureCompare(inputPasswordHash, passwordHash)) {
      throw Exception('Contraseña incorrecta');
    }

    // Actualizar last_login_at
    await db.update(
      'users',
      {'last_login_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userData['id']],
    );

    // Obtener datos actualizados
    final updatedUsers = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userData['id']],
    );

    return UserModel.fromDatabase(updatedUsers.first);
  }

  // Método para generar hash de contraseña
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Método para comparación segura de strings
  bool _secureCompare(String a, String b) {
    if (a.length != b.length) return false;

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }

    return result == 0;
  }

  @override
  Future<void> logout() async {
    // En el futuro, aquí puedes hacer limpieza adicional como invalidar tokens
  }

  @override
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  @override
  Future<void> saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userModel = UserModel.fromEntity(user);
    await prefs.setString(_userSessionKey, jsonEncode(userModel.toDatabase()));
  }

  @override
  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userSessionKey);
  }

  @override
  Future<User> updateUser(User user) async {
    final db = await _databaseHelper.database;
    
    final userModel = UserModel.fromEntity(user);
    
    // Actualizar el usuario en la base de datos
    final count = await db.update(
      'users',
      {
        'name': userModel.name,
        'email': userModel.email,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userModel.id],
    );
    
    if (count == 0) {
      throw Exception('Usuario no encontrado');
    }
    
    // Obtener el usuario actualizado
    final List<Map<String, dynamic>> updatedUsers = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userModel.id],
    );
    
    final updatedUser = UserModel.fromDatabase(updatedUsers.first);
    
    // Actualizar la sesión también
    await saveUserSession(updatedUser);
    
    return updatedUser;
  }

  @override
  Future<void> changePassword(String userId, String currentPassword, String newPassword) async {
    final db = await _databaseHelper.database;
    
    // Verificar el usuario y la contraseña actual
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (users.isEmpty) {
      throw Exception('Usuario no encontrado');
    }
    
    final userData = users.first;
    final storedPasswordHash = userData['password_hash'] as String?;
    
    if (storedPasswordHash == null) {
      throw Exception('Contraseña no configurada para este usuario');
    }
    
    final currentPasswordHash = _hashPassword(currentPassword);
    
    if (!_secureCompare(currentPasswordHash, storedPasswordHash)) {
      throw Exception('Contraseña actual incorrecta');
    }
    
    // Actualizar con la nueva contraseña
    final newPasswordHash = _hashPassword(newPassword);
    
    await db.update(
      'users',
      {
        'password_hash': newPasswordHash,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
