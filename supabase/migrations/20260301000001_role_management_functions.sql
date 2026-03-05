-- Gestión de roles a través de user_profile (schema público).
-- No se accede a auth.users desde funciones de usuario para evitar
-- conflictos con GoTrue en el schema de autenticación.

-- Columna de rol en user_profile
alter table user_profile
  add column if not exists role text not null default 'Adolescent'
    check (role in ('Adolescent', 'ADMIN'));

-- Función para que un ADMIN cambie el rol de otro usuario.
-- Lee y escribe en user_profile, no en auth.users.
create or replace function public.set_user_role(
  target_user_id uuid,
  new_role       text
)
returns void as $$
declare
  caller_role text;
begin
  if new_role not in ('Adolescent', 'ADMIN') then
    raise exception 'Rol no válido: %. Los roles permitidos son Adolescent y ADMIN.', new_role;
  end if;

  select role into caller_role
    from user_profile
   where user_id = auth.uid();

  if caller_role is distinct from 'ADMIN' then
    raise exception 'Acceso denegado: solo un ADMIN puede cambiar roles.';
  end if;

  update user_profile
     set role = new_role
   where user_id = target_user_id;

  if not found then
    raise exception 'Perfil no encontrado para el usuario: %', target_user_id;
  end if;
end;
$$ language plpgsql security definer;

revoke execute on function public.set_user_role(uuid, text) from public, anon;
grant  execute on function public.set_user_role(uuid, text) to authenticated;
