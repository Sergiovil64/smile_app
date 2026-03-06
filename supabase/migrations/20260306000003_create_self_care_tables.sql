-- Tabla de actividades de autocuidado
create table self_care_activity (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  description text not null,
  category    text not null,
  is_active   boolean not null default true,
  created_at  timestamp with time zone not null default now()
);

-- Habilitar Row Level Security
alter table self_care_activity enable row level security;

-- Usuarios autenticados pueden ver las actividades activas
create policy "Authenticated users can view active activities."
  on self_care_activity for select
  using (
    auth.role() = 'authenticated' and is_active = true
  );

-- Admins pueden ver todas las actividades (activas e inactivas)
create policy "Admins can view all activities."
  on self_care_activity for select
  using (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'ADMIN'
  );

-- Solo admins pueden insertar actividades
create policy "Admins can insert activities."
  on self_care_activity for insert
  with check (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'ADMIN'
  );

-- Solo admins pueden actualizar actividades
create policy "Admins can update activities."
  on self_care_activity for update
  using (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'ADMIN'
  );

-- Solo admins pueden eliminar actividades
create policy "Admins can delete activities."
  on self_care_activity for delete
  using (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'ADMIN'
  );


-- Tabla de sesiones de autocuidado (registros por usuario)
create table self_care_session (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  activity_id uuid not null references self_care_activity(id) on delete restrict,
  status      text not null check (status in ('STARTED', 'STOPPED', 'COMPLETED')),
  started_at  timestamp with time zone not null default now(),
  ended_at    timestamp with time zone,
  note        text
);

-- Habilitar Row Level Security
alter table self_care_session enable row level security;

-- Usuarios pueden ver sus propias sesiones
create policy "Users can view their own sessions."
  on self_care_session for select
  using ( auth.uid() = user_id );

-- Admins pueden ver todas las sesiones
create policy "Admins can view all sessions."
  on self_care_session for select
  using (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'ADMIN'
  );

-- Usuarios pueden insertar sus propias sesiones
create policy "Users can insert their own sessions."
  on self_care_session for insert
  with check ( auth.uid() = user_id );

-- Usuarios pueden actualizar sus propias sesiones (cambio de status, agregar nota)
create policy "Users can update their own sessions."
  on self_care_session for update
  using ( auth.uid() = user_id );

-- Usuarios pueden eliminar sus propias sesiones
create policy "Users can delete their own sessions."
  on self_care_session for delete
  using ( auth.uid() = user_id );
