/// Entidad de dominio que representa los datos básicos de un usuario autenticado.
///
/// Contiene únicamente la información mínima proveniente de la sesión de Supabase Auth.
/// Para datos extendidos (nombre, perfil, rol) se utiliza [UserProfileEntity].
class UserEntity {
  /// Identificador único del usuario en Supabase Auth.
  final String id;

  /// Correo electrónico del usuario.
  final String email;

  const UserEntity({
    required this.id,
    required this.email,
  });
}
