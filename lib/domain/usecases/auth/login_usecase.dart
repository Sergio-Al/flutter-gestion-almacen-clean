import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<User> call({
    required String email,
    required String password,
  }) async {
    // Validar formato de email
    if (!_isValidEmail(email)) {
      throw Exception('Formato de email inválido');
    }

    // Validar que la contraseña no esté vacía
    if (password.isEmpty) {
      throw Exception('La contraseña es requerida');
    }

    final user = await _repository.login(email, password);
    await _repository.saveUserSession(user);
    return user;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
