-- Creación de la tabla de registro emocional
create table emotional_log (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references auth.users(id) on delete cascade,
  mood_indicator int not null check (mood_indicator between 1 and 5),
  text_note      text,
  audio_url      text,
  created_at     timestamp with time zone not null default now()
);

-- Habilitar Row Level Security
alter table emotional_log enable row level security;

-- Usuarios pueden ver sus propios registros emocionales
create policy "Users can view their own emotional logs."
  on emotional_log for select
  using ( auth.uid() = user_id );

-- Admins pueden ver todos los registros emocionales
create policy "Admins can view all emotional logs."
  on emotional_log for select
  using (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'ADMIN'
  );

-- Usuarios pueden insertar sus propios registros emocionales
create policy "Users can insert their own emotional logs."
  on emotional_log for insert
  with check ( auth.uid() = user_id );

-- Usuarios pueden eliminar sus propios registros emocionales
create policy "Users can delete their own emotional logs."
  on emotional_log for delete
  using ( auth.uid() = user_id );
