import '../../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<void> call({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Obtener el usuario actual
    final currentUser = await _repository.getCurrentUser();
    if (currentUser == null) {
      throw Exception('No hay usuario autenticado');
    }

    // Validar que las contraseñas nuevas coincidan
    if (newPassword != confirmPassword) {
      throw Exception('Las contraseñas no coinciden');
    }

    // Validar longitud de la nueva contraseña
    if (newPassword.length < 6) {
      throw Exception('La nueva contraseña debe tener al menos 6 caracteres');
    }

    // Validar que la nueva contraseña sea diferente de la actual
    if (currentPassword == newPassword) {
      throw Exception('La nueva contraseña debe ser diferente de la actual');
    }

    // Cambiar la contraseña
    await _repository.changePassword(
      currentUser.id,
      currentPassword,
      newPassword,
    );
  }
}
