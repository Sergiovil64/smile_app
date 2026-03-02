-- Función para cambiar el rol de un usuario.
-- Solo puede ser invocada por un usuario con rol "ADMIN".
-- Roles válidos: 'Adolescent', 'ADMIN'

create or replace function public.set_user_role(
  target_user_id uuid,
  new_role       text
)
returns void as $$
declare
  caller_role text;
begin
  -- Verificar que el rol solicitado sea válido
  if new_role not in ('Adolescent', 'ADMIN') then
    raise exception 'Rol no válido: %. Los roles permitidos son Adolescent y ADMIN.', new_role;
  end if;

  -- Leer el rol del usuario que llama desde su JWT
  caller_role := auth.jwt() -> 'app_metadata' ->> 'role';

  if caller_role <> 'ADMIN' then
    raise exception 'Acceso denegado: solo un ADMIN puede cambiar roles.';
  end if;

  -- Aplicar el cambio en auth.users
  update auth.users
  set raw_app_meta_data =
    coalesce(raw_app_meta_data, '{}'::jsonb) || jsonb_build_object('role', new_role)
  where id = target_user_id;

  if not found then
    raise exception 'Usuario no encontrado: %', target_user_id;
  end if;
end;
$$ language plpgsql security definer;

-- Revocar acceso público y otorgarlo solo a usuarios autenticados
revoke execute on function public.set_user_role(uuid, text) from public, anon;
grant  execute on function public.set_user_role(uuid, text) to authenticated;
