/// Entidad de dominio que representa el perfil completo de un usuario en la app.
///
/// Incluye datos personales, rol y avatar. Se usa para determinar permisos
/// (admin vs adolescente) y mostrar información en la UI.
class UserProfileEntity {
  /// Identificador del usuario (coincide con auth.uid).
  final String id;

  /// Correo electrónico.
  final String email;

  /// Nombre(s).
  final String firstName;

  /// Apellido(s).
  final String lastName;

  /// Género del usuario.
  final String gender;

  /// Fecha de nacimiento.
  final DateTime birthDate;

  /// URL de la imagen de perfil en Supabase Storage (opcional).
  final String? avatarUrl;

  /// Rol del usuario: 'ADMIN' o 'user'. Determina acceso a pantallas admin.
  final String role;

  const UserProfileEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthDate,
    this.avatarUrl,
    this.role = 'user',
  });

  /// Indica si el usuario tiene rol de administrador.
  bool get isAdmin => role == 'ADMIN';
}
