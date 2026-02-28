-- Datos de prueba: 1 usuario por rol

insert into users (id, email, password_hash, role, is_active, created_at)
values
  (
    '00000000-0000-0000-0000-000000000001',
    'admin@gmail.com',
    '$2b$10$placeholderHashForAdminUser000000000000000000000000000',
    'ADMIN',
    true,
    now()
  ),
  (
    '00000000-0000-0000-0000-000000000002',
    'adolescent@gmail.com',
    '$2b$10$placeholderHashForAdolescentUser00000000000000000000000',
    'ADOLESCENT',
    true,
    now()
  );

insert into user_profile (user_id, first_name, last_name, birth_date, photo_url, updated_at)
values
  (
    '00000000-0000-0000-0000-000000000001',
    'Admin',
    'Test',
    '1990-01-15',
    null,
    now()
  ),
  (
    '00000000-0000-0000-0000-000000000002',
    'Juan',
    'Pérez',
    '2008-06-20',
    null,
    now()
  );
