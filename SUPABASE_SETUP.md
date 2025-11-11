# Supabase Setup Guide

This app supports both **Firebase** (NoSQL) and **Supabase** (PostgreSQL) as database backends. You can use either one or both together.

## 🎯 Why Use Supabase?

- **PostgreSQL Power**: Advanced queries, joins, and relationships
- **Cost-effective**: More generous free tier for certain workloads
- **Open Source**: Self-hostable and transparent
- **Real-time**: Built-in real-time subscriptions
- **Better Analytics**: SQL queries for complex analytics

## 📋 Setup Steps

### 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Create a new organization and project
4. Wait for the project to be provisioned (~2 minutes)

### 2. Get Your Credentials

1. In your Supabase project dashboard, go to **Settings** > **API**
2. Copy your **Project URL** (looks like `https://xxxxx.supabase.co`)
3. Copy your **anon/public** key

### 3. Configure the App

Update `lib/core/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
}
```

Or use environment variables:

```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co \
           --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### 4. Create Database Tables

In your Supabase project, go to **SQL Editor** and run these SQL commands:

#### Users Table

```sql
create table users (
  id uuid primary key,
  username text unique not null,
  email text unique not null,
  display_name text not null,
  bio text default '',
  photo_url text default '',
  followers_count int default 0,
  following_count int default 0,
  posts_count int default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Indexes for better performance
create index users_username_idx on users(username);
create index users_email_idx on users(email);

-- Enable Row Level Security
alter table users enable row level security;

-- Policy: Users can read all profiles
create policy "Users can view all profiles"
  on users for select
  using (true);

-- Policy: Users can update their own profile
create policy "Users can update own profile"
  on users for update
  using (auth.uid() = id);
```

#### Posts Table

```sql
create table posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade not null,
  caption text default '',
  image_urls text[] not null,
  location text default '',
  likes int default 0,
  comments int default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Indexes
create index posts_user_id_idx on posts(user_id);
create index posts_created_at_idx on posts(created_at desc);

-- Enable RLS
alter table posts enable row level security;

-- Policy: Anyone can view posts
create policy "Anyone can view posts"
  on posts for select
  using (true);

-- Policy: Users can create their own posts
create policy "Users can create posts"
  on posts for insert
  with check (auth.uid() = user_id);

-- Policy: Users can delete their own posts
create policy "Users can delete own posts"
  on posts for delete
  using (auth.uid() = user_id);
```

#### Likes Table

```sql
create table likes (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references posts(id) on delete cascade not null,
  user_id uuid references users(id) on delete cascade not null,
  created_at timestamptz default now(),
  unique(post_id, user_id)
);

-- Indexes
create index likes_post_id_idx on likes(post_id);
create index likes_user_id_idx on likes(user_id);

-- Enable RLS
alter table likes enable row level security;

-- Policy: Anyone can view likes
create policy "Anyone can view likes"
  on likes for select
  using (true);

-- Policy: Authenticated users can like posts
create policy "Users can like posts"
  on likes for insert
  with check (auth.uid() = user_id);

-- Policy: Users can unlike posts
create policy "Users can unlike posts"
  on likes for delete
  using (auth.uid() = user_id);
```

#### Comments Table

```sql
create table comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references posts(id) on delete cascade not null,
  user_id uuid references users(id) on delete cascade not null,
  text text not null,
  likes int default 0,
  created_at timestamptz default now()
);

-- Indexes
create index comments_post_id_idx on comments(post_id);
create index comments_created_at_idx on comments(created_at);

-- Enable RLS
alter table comments enable row level security;

-- Policy: Anyone can view comments
create policy "Anyone can view comments"
  on comments for select
  using (true);

-- Policy: Authenticated users can comment
create policy "Users can create comments"
  on comments for insert
  with check (auth.uid() = user_id);
```

#### Follows Table

```sql
create table follows (
  id uuid primary key default gen_random_uuid(),
  follower_id uuid references users(id) on delete cascade not null,
  following_id uuid references users(id) on delete cascade not null,
  created_at timestamptz default now(),
  unique(follower_id, following_id),
  check (follower_id != following_id)
);

-- Indexes
create index follows_follower_id_idx on follows(follower_id);
create index follows_following_id_idx on follows(following_id);

-- Enable RLS
alter table follows enable row level security;

-- Policy: Anyone can view follows
create policy "Anyone can view follows"
  on follows for select
  using (true);

-- Policy: Users can follow others
create policy "Users can follow"
  on follows for insert
  with check (auth.uid() = follower_id);

-- Policy: Users can unfollow
create policy "Users can unfollow"
  on follows for delete
  using (auth.uid() = follower_id);
```

### 5. Create Database Functions

These functions handle counter updates and feed queries:

#### Increment/Decrement Functions

```sql
-- Increment post likes
create or replace function increment_post_likes(post_id uuid)
returns void as $$
begin
  update posts set likes = likes + 1 where id = post_id;
end;
$$ language plpgsql;

-- Decrement post likes
create or replace function decrement_post_likes(post_id uuid)
returns void as $$
begin
  update posts set likes = greatest(likes - 1, 0) where id = post_id;
end;
$$ language plpgsql;

-- Increment follower count
create or replace function increment_follower_count(user_id uuid)
returns void as $$
begin
  update users set followers_count = followers_count + 1 where id = user_id;
end;
$$ language plpgsql;

-- Decrement follower count
create or replace function decrement_follower_count(user_id uuid)
returns void as $$
begin
  update users set followers_count = greatest(followers_count - 1, 0) where id = user_id;
end;
$$ language plpgsql;

-- Increment following count
create or replace function increment_following_count(user_id uuid)
returns void as $$
begin
  update users set following_count = following_count + 1 where id = user_id;
end;
$$ language plpgsql;

-- Decrement following count
create or replace function decrement_following_count(user_id uuid)
returns void as $$
begin
  update users set following_count = greatest(following_count - 1, 0) where id = user_id;
end;
$$ language plpgsql;
```

#### Feed Query Function

```sql
-- Get feed posts (posts from followed users)
create or replace function get_feed_posts(current_user_id uuid)
returns table (
  id uuid,
  user_id uuid,
  username text,
  photo_url text,
  caption text,
  image_urls text[],
  location text,
  likes int,
  comments int,
  created_at timestamptz
) as $$
begin
  return query
  select
    p.id,
    p.user_id,
    u.username,
    u.photo_url,
    p.caption,
    p.image_urls,
    p.location,
    p.likes,
    p.comments,
    p.created_at
  from posts p
  join users u on p.user_id = u.id
  where p.user_id in (
    select following_id
    from follows
    where follower_id = current_user_id
  )
  or p.user_id = current_user_id
  order by p.created_at desc
  limit 50;
end;
$$ language plpgsql;
```

### 6. Enable Real-time (Optional)

In your Supabase project:

1. Go to **Database** > **Replication**
2. Enable replication for tables you want to listen to:
   - `posts`
   - `likes`
   - `comments`
   - `follows`

## 🔄 Hybrid Mode (Firebase + Supabase)

The app supports using both databases simultaneously:

- **Primary**: Supabase (PostgreSQL for advanced queries)
- **Fallback**: Firebase (if Supabase fails)
- **Dual-write**: Optionally write to both databases

Enable dual-write mode in `HybridDatabaseService`:

```dart
final hybridDb = HybridDatabaseService(
  primaryBackend: DatabaseBackend.supabase,
  useDualWrite: true, // Write to both Firebase and Supabase
);
```

## 🌐 Web Platform Support

The app is fully configured for web deployment:

- Responsive design for desktop/tablet/mobile browsers
- PWA (Progressive Web App) support
- Firebase and Supabase both work on web

### Running on Web

```bash
flutter run -d chrome
```

### Building for Web

```bash
flutter build web --release
```

Deploy the `build/web` directory to:
- Firebase Hosting
- Vercel
- Netlify
- Any static hosting provider

## 📱 Mobile Platform Support

The app supports both iOS and Android:

### iOS Requirements

- macOS with Xcode installed
- CocoaPods: `sudo gem install cocoapods`
- iOS 12.0 or higher

### Android Requirements

- Android Studio with Android SDK
- Android 5.0 (API 21) or higher

### Running on Mobile

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

## 🎨 Platform Detection

The app automatically detects the platform and adjusts:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

if (kIsWeb) {
  // Web-specific code
} else {
  // Mobile-specific code
}
```

## 📊 Performance Tips

### For Web
- Use CDN for images
- Enable caching
- Lazy load images
- Use web-optimized image formats (WebP)

### For Mobile
- Cache network images
- Use pagination for lists
- Optimize image sizes
- Enable offline mode

## 🔒 Security

- **Row Level Security (RLS)** enabled on all tables
- **API keys** stored in environment variables
- **HTTPS** required for all connections
- **OAuth** for authentication

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Web Documentation](https://flutter.dev/web)
- [Firebase Documentation](https://firebase.google.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
