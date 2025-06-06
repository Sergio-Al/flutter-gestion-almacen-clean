import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class UpdateUserUseCase {
  final AuthRepository _repository;

  UpdateUserUseCase(this._repository);

  Future<User> call({
    required String id,
    required String name,
    required String email,
  }) async {
    // Validar formato de email
    if (!_isValidEmail(email)) {
      throw Exception('Formato de email inválido');
    }

    // Validar que el nombre no esté vacío
    if (name.trim().isEmpty) {
      throw Exception('El nombre es requerido');
    }

    // Obtener el usuario actual para mantener otros campos
    final currentUser = await _repository.getCurrentUser();
    if (currentUser == null) {
      throw Exception('No hay usuario autenticado');
    }

    if (currentUser.id != id) {
      throw Exception('No se puede actualizar otro usuario');
    }

    // Crear el usuario actualizado
    final updatedUser = currentUser.copyWith(
      name: name.trim(),
      email: email.trim(),
    );

    return await _repository.updateUser(updatedUser);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
