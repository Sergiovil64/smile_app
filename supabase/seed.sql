-- Datos de prueba: 1 usuario Admin + 1 usuario Adolescent
-- Contraseña de ambos: Test1234!

-- 1. Insertar usuarios en auth.users ─────────────────────────────────────────
insert into auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
)
values
  (
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'admin@smile.test',
    extensions.crypt('Test1234!', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"],"role":"ADMIN"}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  ),
  (
    '00000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'juan@smile.test',
    extensions.crypt('Test1234!', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"],"role":"Adolescent"}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  )
on conflict (id) do nothing;

-- 2. Insertar perfiles en user_profile ────────────────────────────────────────
insert into user_profile (user_id, first_name, last_name, gender, birth_date, photo_url, updated_at)
values
  (
    '00000000-0000-0000-0000-000000000001',
    'Admin',
    'Test',
    'Masculino',
    '1990-01-15',
    null,
    now()
  ),
  (
    '00000000-0000-0000-0000-000000000002',
    'Juan',
    'Pérez',
    'Masculino',
    '2008-06-20',
    null,
    now()
  )
on conflict (user_id) do nothing;
