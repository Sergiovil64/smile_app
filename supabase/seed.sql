-- Datos de prueba – SOLO para desarrollo local (supabase start).
--
-- En el proyecto remoto los usuarios se crean desde el dashboard de Supabase
-- (Authentication → Users → Add user) y el rol se asigna manualmente:
--
--   UPDATE user_profile SET role = 'ADMIN' WHERE user_id = '<uuid>';
--
-- ─────────────────────────────────────────────────────────────────────────────
-- USUARIOS (local únicamente)
-- ─────────────────────────────────────────────────────────────────────────────
insert into auth.users (
  id, instance_id, aud, role, email,
  encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
)
values
  (
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated',
    'admin@smile.test',
    extensions.crypt('Test1234!', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(), now()
  ),
  (
    '00000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated',
    'juan@smile.test',
    extensions.crypt('Test1234!', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(), now()
  )
on conflict (id) do nothing;

-- IDENTIDADES
insert into auth.identities (
  id, user_id, provider_id, provider,
  identity_data, created_at, updated_at, last_sign_in_at
)
values
  (
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    'admin@smile.test', 'email',
    '{"sub":"00000000-0000-0000-0000-000000000001","email":"admin@smile.test"}'::jsonb,
    now(), now(), now()
  ),
  (
    '00000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000002',
    'juan@smile.test', 'email',
    '{"sub":"00000000-0000-0000-0000-000000000002","email":"juan@smile.test"}'::jsonb,
    now(), now(), now()
  )
on conflict (provider, provider_id) do nothing;

-- PERFILES
insert into user_profile (user_id, first_name, last_name, gender, birth_date, photo_url, role, updated_at)
values
  (
    '00000000-0000-0000-0000-000000000001',
    'Admin', 'Test', 'Masculino', '1990-01-15', null, 'ADMIN', now()
  ),
  (
    '00000000-0000-0000-0000-000000000002',
    'Juan', 'Pérez', 'Masculino', '2008-06-20', null, 'Adolescent', now()
  )
on conflict (user_id) do nothing;
