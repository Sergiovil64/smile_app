-- Creación de la tabla de perfil de usuario
create table user_profile (
  user_id uuid primary key references auth.users(id) on delete cascade,
  first_name text not null,
  last_name text not null,
  birth_date date not null,
  gender text not null,
  photo_url text,
  updated_at timestamp with time zone not null default now()
);

-- Habilitar Row Level Security
alter table user_profile enable row level security;

create policy "Users can view their own profile."
  on user_profile for select
  using ( auth.uid() = user_id );

create policy "Admins can view all profiles."
  on user_profile for select
  using (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'ADMIN'
  );

create policy "Users can insert their own profile."
  on user_profile for insert
  with check ( auth.uid() = user_id );

create policy "Users can update their own profile."
  on user_profile for update
  using ( auth.uid() = user_id );

create policy "Admins can update any profile."
  on user_profile for update
  using (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'ADMIN'
  );

-- Trigger para actualizar el campo updated_at automáticamente
create or replace function update_user_profile_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger set_user_profile_updated_at
  before update on user_profile
  for each row
  execute function update_user_profile_updated_at();
