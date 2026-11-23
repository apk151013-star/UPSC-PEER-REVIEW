create table public.admins (user_id uuid primary key references auth.users(id) on delete cascade);
create table public.stacks (
  id uuid primary key default gen_random_uuid(),
  label text not null, title text not null, body text not null,
  max_marks numeric(6,2) not null check (max_marks>0),
  deadline timestamptz, color text not null default 'red' check (color in ('red','dark','white')),
  created_at timestamptz not null default now());
create table public.submissions (
  id uuid primary key default gen_random_uuid(),
  stack_id uuid not null references public.stacks(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  who text not null check (char_length(who) between 1 and 40),
  note text check (char_length(note)<=600),
  files jsonb not null default '[]', late boolean not null default false,
  created_at timestamptz not null default now(),
  unique (stack_id, user_id));
create index on public.submissions(stack_id, created_at desc);

create function public.is_admin() returns boolean language sql stable security definer set search_path=public as
$$ select exists(select 1 from admins where user_id=auth.uid()) $$;

alter table admins enable row level security;
alter table stacks enable row level security;
alter table submissions enable row level security;
create policy adm_self on admins for select to authenticated using (user_id=auth.uid());   -- nobody can insert: owner adds via SQL editor
create policy st_read on stacks for select to authenticated using (true);
create policy st_ins on stacks for insert to authenticated with check (is_admin());
create policy st_upd on stacks for update to authenticated using (is_admin());
create policy st_del on stacks for delete to authenticated using (is_admin());
create policy sub_read on submissions for select to authenticated using (true);
create policy sub_ins on submissions for insert to authenticated with check (user_id=auth.uid());
create policy sub_upd on submissions for update to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy sub_del on submissions for delete to authenticated using (user_id=auth.uid() or is_admin());

insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('answers','answers',true,20971520,array['application/pdf','image/jpeg','image/png','image/webp']) on conflict (id) do nothing;
create policy ans_up on storage.objects for insert to authenticated with check (bucket_id='answers' and (storage.foldername(name))[1]=auth.uid()::text);
create policy ans_del on storage.objects for delete to authenticated using (bucket_id='answers' and ((storage.foldername(name))[1]=auth.uid()::text or is_admin()));

-- AFTER you sign up with your own email, make yourself the owner (run once):
-- insert into admins select id from auth.users where email='you@example.com';
