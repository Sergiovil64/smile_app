/// El usuario ya existe en auth pero no tiene perfil creado.
/// Ocurre cuando signUp tuvo éxito pero createProfile falló en un intento previo.
class IncompleteRegistrationException implements Exception {
  final String userId;
  final String message;
  const IncompleteRegistrationException(this.userId, this.message);
}

/// Falló la creación del perfil después de que el usuario auth ya fue creado.
/// La sesión fue cerrada como limpieza, pero el usuario auth huérfano persiste.
class ProfileCreationException implements Exception {
  final String userId;
  final String message;
  const ProfileCreationException(this.userId, this.message);
}
