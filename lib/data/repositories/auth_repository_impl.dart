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
    return UserModel.fromMap(userMap);
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
    
    // En un sistema real, aquí verificarías el hash de la contraseña
    // Por ahora, simplificamos la validación
    if (userData['password'] != password) {
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
    
    return UserModel.fromMap(updatedUsers.first);
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
    await prefs.setString(_userSessionKey, jsonEncode(userModel.toMap()));
  }

  @override
  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userSessionKey);
  }
}
