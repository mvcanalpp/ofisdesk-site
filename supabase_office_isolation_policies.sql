-- OfisDesk office isolation policies
-- Run this in Supabase SQL Editor before selling/activating customer offices.

create or replace function public.ofisdesk_is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and (
        lower(coalesce(p.role, '')) in ('admin', 'kurucu', 'founder')
        or lower(coalesce(p.username, '')) = 'admin'
      )
  );
$$;

create or replace function public.ofisdesk_user_office_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select p.office_id
  from public.profiles p
  where p.id = auth.uid()
  limit 1;
$$;

create or replace function public.ofisdesk_same_office(target_office_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.ofisdesk_is_admin()
      or target_office_id = public.ofisdesk_user_office_id();
$$;

alter table public.accounting_records enable row level security;
alter table public.accounting_institutions enable row level security;
alter table public.office_personnel_data enable row level security;

drop policy if exists ofisdesk_accounting_records_select on public.accounting_records;
create policy ofisdesk_accounting_records_select
on public.accounting_records
for select
using (public.ofisdesk_same_office(office_id));

drop policy if exists ofisdesk_accounting_records_insert on public.accounting_records;
create policy ofisdesk_accounting_records_insert
on public.accounting_records
for insert
with check (public.ofisdesk_same_office(office_id));

drop policy if exists ofisdesk_accounting_records_update on public.accounting_records;
create policy ofisdesk_accounting_records_update
on public.accounting_records
for update
using (public.ofisdesk_same_office(office_id))
with check (public.ofisdesk_same_office(office_id));

drop policy if exists ofisdesk_accounting_records_delete on public.accounting_records;
create policy ofisdesk_accounting_records_delete
on public.accounting_records
for delete
using (public.ofisdesk_same_office(office_id));

drop policy if exists ofisdesk_accounting_institutions_select on public.accounting_institutions;
create policy ofisdesk_accounting_institutions_select
on public.accounting_institutions
for select
using (public.ofisdesk_same_office(office_id));

drop policy if exists ofisdesk_accounting_institutions_insert on public.accounting_institutions;
create policy ofisdesk_accounting_institutions_insert
on public.accounting_institutions
for insert
with check (public.ofisdesk_same_office(office_id));

drop policy if exists ofisdesk_accounting_institutions_update on public.accounting_institutions;
create policy ofisdesk_accounting_institutions_update
on public.accounting_institutions
for update
using (public.ofisdesk_same_office(office_id))
with check (public.ofisdesk_same_office(office_id));

drop policy if exists ofisdesk_accounting_institutions_delete on public.accounting_institutions;
create policy ofisdesk_accounting_institutions_delete
on public.accounting_institutions
for delete
using (public.ofisdesk_same_office(office_id));

drop policy if exists ofisdesk_office_personnel_data_select on public.office_personnel_data;
create policy ofisdesk_office_personnel_data_select
on public.office_personnel_data
for select
using (public.ofisdesk_same_office(office_id));

drop policy if exists ofisdesk_office_personnel_data_insert on public.office_personnel_data;
create policy ofisdesk_office_personnel_data_insert
on public.office_personnel_data
for insert
with check (public.ofisdesk_same_office(office_id));

drop policy if exists ofisdesk_office_personnel_data_update on public.office_personnel_data;
create policy ofisdesk_office_personnel_data_update
on public.office_personnel_data
for update
using (public.ofisdesk_same_office(office_id))
with check (public.ofisdesk_same_office(office_id));

drop policy if exists ofisdesk_office_personnel_data_delete on public.office_personnel_data;
create policy ofisdesk_office_personnel_data_delete
on public.office_personnel_data
for delete
using (public.ofisdesk_same_office(office_id));
