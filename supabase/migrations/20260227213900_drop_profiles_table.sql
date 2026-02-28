-- Quitar la tabla de perfiles (Tabla por defecto de Supabase) y todos los objetos asociados

-- Quitar de la publicación realtime si fue agregada
do $$
begin
  alter publication supabase_realtime drop table profiles;
exception when others then
  null; -- ignorar si la tabla no estaba en la publicación
end;
$$;

-- Quitar políticas RLS
drop policy if exists "Public profiles are viewable by everyone." on profiles;
drop policy if exists "Users can insert their own profile." on profiles;
drop policy if exists "Users can update own profile." on profiles;

-- Quitar políticas de almacenamiento asociadas al bucket de avatars
drop policy if exists "Avatar images are publicly accessible." on storage.objects;
drop policy if exists "Anyone can upload an avatar." on storage.objects;

-- Quitar la tabla
drop table if exists profiles;
