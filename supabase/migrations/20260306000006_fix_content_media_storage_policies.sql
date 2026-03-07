-- Función auxiliar que verifica si el usuario actual es ADMIN
-- security definer = corre con privilegios del owner (bypassa RLS en user_profile)
create or replace function public.is_current_user_admin()
returns boolean as $$
  select exists (
    select 1 from public.user_profile
    where user_id = auth.uid()
      and role = 'ADMIN'
  );
$$ language sql security definer stable;

-- Eliminar políticas anteriores que usaban app_metadata (no funcionan)
drop policy if exists "Admins can upload content media."   on storage.objects;
drop policy if exists "Admins can update content media."   on storage.objects;
drop policy if exists "Admins can delete content media."   on storage.objects;
drop policy if exists "Authenticated users can read content media." on storage.objects;

-- Recrear políticas usando la función helper
create policy "Admins can upload content media."
  on storage.objects for insert
  with check (
    bucket_id = 'content_media'
    and public.is_current_user_admin()
  );

create policy "Authenticated users can read content media."
  on storage.objects for select
  using (
    bucket_id = 'content_media'
    and auth.role() = 'authenticated'
  );

create policy "Admins can update content media."
  on storage.objects for update
  using (
    bucket_id = 'content_media'
    and public.is_current_user_admin()
  );

create policy "Admins can delete content media."
  on storage.objects for delete
  using (
    bucket_id = 'content_media'
    and public.is_current_user_admin()
  );
