class UserProfileEntity {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final DateTime birthDate;
  final String? avatarUrl;
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

  bool get isAdmin => role == 'ADMIN';
}
