-- Creación del bucket para almacenar notas de audio de registros emocionales
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'audio_logs',
  'audio_logs',
  false,
  10485760,
  ARRAY['audio/mpeg', 'audio/mp4', 'audio/x-m4a', 'audio/wav', 'audio/ogg', 'audio/webm', 'audio/aac']
) on conflict (id) do nothing;

-- Habilitar RLS en storage.objects (ya está habilitado por defecto en Supabase)

-- Usuarios pueden subir sus propios archivos de audio (carpeta = user_id)
create policy "Users can upload their own audio logs."
  on storage.objects for insert
  with check (
    bucket_id = 'audio_logs'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- Usuarios pueden leer sus propios archivos de audio
create policy "Users can read their own audio logs."
  on storage.objects for select
  using (
    bucket_id = 'audio_logs'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- Usuarios pueden eliminar sus propios archivos de audio
create policy "Users can delete their own audio logs."
  on storage.objects for delete
  using (
    bucket_id = 'audio_logs'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- Admins pueden leer todos los archivos de audio
create policy "Admins can read all audio logs."
  on storage.objects for select
  using (
    bucket_id = 'audio_logs'
    and (auth.jwt() -> 'app_metadata' ->> 'role') = 'ADMIN'
  );
