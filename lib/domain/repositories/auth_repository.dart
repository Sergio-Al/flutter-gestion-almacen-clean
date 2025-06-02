import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> login(String email, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<void> saveUserSession(User user);
  Future<void> clearUserSession();
}
