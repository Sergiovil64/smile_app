-- Creación de la tabla de contenido educacional
create table educational_content (
  id                uuid primary key default gen_random_uuid(),
  created_by_admin_id uuid not null references auth.users(id) on delete restrict,
  title             text not null,
  description       text not null,
  type              text not null check (type in ('TEXT', 'AUDIO', 'VIDEO')),
  body_text         text,
  media_url         text,
  cover_image_url   text,
  is_published      boolean not null default false,
  created_at        timestamp with time zone not null default now(),
  updated_at        timestamp with time zone not null default now()
);

-- Habilitar Row Level Security
alter table educational_content enable row level security;

-- Usuarios autenticados pueden ver el contenido publicado
create policy "Authenticated users can view published content."
  on educational_content for select
  using (
    auth.role() = 'authenticated' and is_published = true
  );

-- Admins pueden ver todo el contenido (publicado y no publicado)
create policy "Admins can view all educational content."
  on educational_content for select
  using (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'ADMIN'
  );

-- Solo admins pueden insertar contenido
create policy "Admins can insert educational content."
  on educational_content for insert
  with check (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'ADMIN'
  );

-- Solo admins pueden actualizar contenido
create policy "Admins can update educational content."
  on educational_content for update
  using (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'ADMIN'
  );

-- Solo admins pueden eliminar contenido
create policy "Admins can delete educational content."
  on educational_content for delete
  using (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'ADMIN'
  );

-- Trigger para actualizar el campo updated_at automáticamente
create or replace function update_educational_content_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger set_educational_content_updated_at
  before update on educational_content
  for each row
  execute function update_educational_content_updated_at();
