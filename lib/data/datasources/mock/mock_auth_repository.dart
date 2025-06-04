import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../models/user_model.dart';

class MockAuthRepository implements AuthRepository {
  static const String _userSessionKey = 'user_session';
  
  // Mock users para desarrollo
  static final List<UserModel> _mockUsers = [
    UserModel(
      id: 'user-1',
      email: 'admin@almacen.com',
      name: 'Administrador',
      role: 'admin',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    UserModel(
      id: 'user-2',
      email: 'gerente@almacen.com',
      name: 'Gerente de Almacén',
      role: 'manager',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    UserModel(
      id: 'user-3',
      email: 'operador@almacen.com',
      name: 'Operador',
      role: 'operator',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      lastLoginAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

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
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Buscar usuario mock
    UserModel? user;
    try {
      user = _mockUsers.firstWhere((u) => u.email == email);
    } catch (e) {
      user = null;
    }
    
    if (user == null) {
      throw Exception('Usuario no encontrado');
    }
    
    // Para el mock, cualquier contraseña que no esté vacía es válida
    if (password.isEmpty) {
      throw Exception('Contraseña incorrecta');
    }
    
    // Actualizar lastLoginAt
    final updatedUser = UserModel.fromEntity(user.copyWith(
      lastLoginAt: DateTime.now(),
    ));
    
    return updatedUser;
  }

  @override
  Future<void> logout() async {
    // Simular delay
    await Future.delayed(const Duration(milliseconds: 300));
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
}
