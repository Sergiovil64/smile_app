-- Eliminar políticas que usaban app_metadata (no funcionan con este proyecto)
drop policy if exists "Admins can view all educational content."   on educational_content;
drop policy if exists "Admins can insert educational content."     on educational_content;
drop policy if exists "Admins can update educational content."     on educational_content;
drop policy if exists "Admins can delete educational content."     on educational_content;

-- Recrear usando la función is_current_user_admin() que lee user_profile.role
create policy "Admins can view all educational content."
  on educational_content for select
  using (public.is_current_user_admin());

create policy "Admins can insert educational content."
  on educational_content for insert
  with check (public.is_current_user_admin());

create policy "Admins can update educational content."
  on educational_content for update
  using (public.is_current_user_admin());

create policy "Admins can delete educational content."
  on educational_content for delete
  using (public.is_current_user_admin());
