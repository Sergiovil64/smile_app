-- Enumerado para los roles de usuario
create type user_role as enum ('ADOLESCENT', 'ADMIN');

-- Creación de la tabla de usuarios
create table users (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  password_hash text not null,
  role user_role not null default 'ADOLESCENT',
  is_active boolean not null default true,
  created_at timestamp with time zone not null default now(),
  last_login_at timestamp with time zone
);

-- Habilitar Row Level Security
alter table users enable row level security;

create policy "Admins can view all users."
  on users for select
  using (
    exists (
      select 1 from users u
      where u.id = auth.uid() and u.role = 'ADMIN'
    )
  );

create policy "Users can view their own record."
  on users for select
  using ( auth.uid() = id );

create policy "Admins can insert users."
  on users for insert
  with check (
    exists (
      select 1 from users u
      where u.id = auth.uid() and u.role = 'ADMIN'
    )
  );

create policy "Admins can update users."
  on users for update
  using (
    exists (
      select 1 from users u
      where u.id = auth.uid() and u.role = 'ADMIN'
    )
  );
