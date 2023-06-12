-- uuidを使って一意の値を設定
-- 認証用のuser id を参照
create table blogs (
  id uuid not null default uuid_generate_v4(),
  user_id uuid references auth.users not null, 
  title text not null,
  content text not null,
  image_url text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,

  primary key (id)

);

alter table blogs enable row level security;
create policy "ブログは誰でも参照可能" on blogs for select using ( true );
create policy "自身のブログを追加" on blogs for insert with check (auth.uid() = user_id);
create policy "自身のブログを更新" on blogs for update using (auth.uid() = user_id);
create policy "自身のブログを削除" on blogs for delete using (auth.uid() = user_id);

create table profiles (
  id uuid primary key references auth.users on delete cascade,
  email text not null,
  name text,
  avatar_url text
)

alter table profiles enable row level security;
create policy "プロフィールは誰でも参照可能" on profiles for select using ( true );
create policy "自身のプロフィールを更新" on profiles for update using (auth.uid() = id):

create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email);
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger on_auth_usercreated
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

insert into storage.buckets (id, name, public) values ('blogs', 'blogs', true);
create policy "画像は誰でも参照可能" on storage.objects for select using ( bucket_id = 'blogs' );
create policy "画像はログインユーザーが追加可能" on storage.objects for insert with check ( bucket_id = 'blogs' AND role() = 'authenticated');
create policy "自身の画像を更新" on storage.objects for update with check ( bucket_id = 'blogs' AND uid() = owner);
create policy "自身の画像を削除" on storage.objects for delete using ( bucket_id = 'blogs' AND uid() = owner);

insert into storage.buckets (id, name, public) values ('plofile', 'plofile', true);
create policy "プロフィール画像は誰でも参照可能" on storage.objects for select using ( bucket_id = 'profile' );
create policy "プロフィール画像はログインユーザーが追加可能" on storage.objects for insert with check ( bucket_id = 'profile' AND role() = 'authenticated');
create policy "自身のプロフィール画像を更新" on storage.objects for update with check ( bucket_id = 'profile' AND uid() = owner);
create policy "自身のプロフィール画像を削除" on storage.objects for delete using ( bucket_id = 'profile' AND uid() = owner);