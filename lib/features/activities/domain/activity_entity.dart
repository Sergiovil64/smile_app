/// Entidad de dominio que representa una actividad de autocuidado.
///
/// Las actividades son sugerencias de ejercicios o prácticas para el bienestar
/// emocional, organizadas por categoría. Se muestran en la pestaña Actividades.
class ActivityEntity {
  /// Identificador único de la actividad.
  final String id;

  /// Título de la actividad.
  final String title;

  /// Descripción detallada de la actividad.
  final String description;

  /// Categoría de la actividad (ej. respiración, mindfulness).
  final String category;

  /// Si la actividad está activa y visible para los usuarios.
  final bool isActive;

  /// Fecha de creación.
  final DateTime createdAt;

  const ActivityEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isActive,
    required this.createdAt,
  });
}
