-- OfisDesk Web Dosya Foyu bulut esitleme tablolari
-- Supabase SQL Editor'de calistirilacak taslak.

create table if not exists public.case_foys (
  id uuid primary key default gen_random_uuid(),
  office_id uuid not null,
  name text not null,
  is_active boolean not null default true,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (office_id, name)
);

create table if not exists public.case_foy_rows (
  id uuid primary key default gen_random_uuid(),
  office_id uuid not null,
  foy_id uuid not null references public.case_foys(id) on delete cascade,
  row_data jsonb not null default '{}'::jsonb,
  last_modified_by uuid,
  last_modified_by_name text,
  last_modified_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists public.case_foy_backups (
  id uuid primary key default gen_random_uuid(),
  office_id uuid not null,
  foy_id uuid not null references public.case_foys(id) on delete cascade,
  label text not null,
  rows_snapshot jsonb not null default '[]'::jsonb,
  created_by uuid,
  created_by_name text,
  created_at timestamptz not null default now()
);

alter table public.case_foys enable row level security;
alter table public.case_foy_rows enable row level security;
alter table public.case_foy_backups enable row level security;

drop policy if exists "case_foys_same_office_select" on public.case_foys;
create policy "case_foys_same_office_select" on public.case_foys
for select using (
  office_id in (select office_id from public.profiles where id = auth.uid())
);

drop policy if exists "case_foys_same_office_write" on public.case_foys;
create policy "case_foys_same_office_write" on public.case_foys
for all using (
  office_id in (select office_id from public.profiles where id = auth.uid())
) with check (
  office_id in (select office_id from public.profiles where id = auth.uid())
);

drop policy if exists "case_foy_rows_same_office_select" on public.case_foy_rows;
create policy "case_foy_rows_same_office_select" on public.case_foy_rows
for select using (
  office_id in (select office_id from public.profiles where id = auth.uid())
);

drop policy if exists "case_foy_rows_same_office_write" on public.case_foy_rows;
create policy "case_foy_rows_same_office_write" on public.case_foy_rows
for all using (
  office_id in (select office_id from public.profiles where id = auth.uid())
) with check (
  office_id in (select office_id from public.profiles where id = auth.uid())
);

drop policy if exists "case_foy_backups_same_office_select" on public.case_foy_backups;
create policy "case_foy_backups_same_office_select" on public.case_foy_backups
for select using (
  office_id in (select office_id from public.profiles where id = auth.uid())
);

drop policy if exists "case_foy_backups_same_office_write" on public.case_foy_backups;
create policy "case_foy_backups_same_office_write" on public.case_foy_backups
for all using (
  office_id in (select office_id from public.profiles where id = auth.uid())
) with check (
  office_id in (select office_id from public.profiles where id = auth.uid())
);
