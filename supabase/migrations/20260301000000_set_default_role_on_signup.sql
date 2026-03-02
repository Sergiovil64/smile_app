-- Asigna automáticamente el rol "Adolescent" a todo usuario que se registre

create or replace function public.set_default_role()
returns trigger as $$
begin
  if (new.raw_app_meta_data ->> 'role') is null then
    update auth.users
    set raw_app_meta_data =
      coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role": "Adolescent"}'::jsonb
    where id = new.id;
  end if;
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created_set_role
  after insert on auth.users
  for each row
  execute function public.set_default_role();
