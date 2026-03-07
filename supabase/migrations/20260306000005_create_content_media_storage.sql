-- Creación del bucket para almacenar archivos multimedia del contenido educativo
-- (portadas, audios, videos y documentos)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'content_media',
  'content_media',
  true,
  209715200, -- 200 MB
  ARRAY[
    -- Imágenes (portadas)
    'image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif',
    -- Audio
    'audio/mpeg', 'audio/mp4', 'audio/x-m4a', 'audio/wav', 'audio/ogg',
    'audio/webm', 'audio/aac',
    -- Video
    'video/mp4', 'video/quicktime', 'video/x-msvideo', 'video/webm',
    'video/mpeg', 'video/3gpp',
    -- Documentos
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'text/plain'
  ]
) on conflict (id) do nothing;

-- Solo admins pueden subir archivos
create policy "Admins can upload content media."
  on storage.objects for insert
  with check (
    bucket_id = 'content_media'
    and (auth.jwt() -> 'app_metadata' ->> 'role') = 'ADMIN'
  );

-- Usuarios autenticados pueden leer el contenido (bucket público)
create policy "Authenticated users can read content media."
  on storage.objects for select
  using (
    bucket_id = 'content_media'
    and auth.role() = 'authenticated'
  );

-- Solo admins pueden actualizar archivos (upsert)
create policy "Admins can update content media."
  on storage.objects for update
  using (
    bucket_id = 'content_media'
    and (auth.jwt() -> 'app_metadata' ->> 'role') = 'ADMIN'
  );

-- Solo admins pueden eliminar archivos
create policy "Admins can delete content media."
  on storage.objects for delete
  using (
    bucket_id = 'content_media'
    and (auth.jwt() -> 'app_metadata' ->> 'role') = 'ADMIN'
  );
