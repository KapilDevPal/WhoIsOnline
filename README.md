# WhoIsOnline

Track "who is online right now?" in Rails 7+ using Redis TTL. No database writes, production-safe, and auto-hooks into controllers via a Rails Engine.

## Features
- **Activity-based tracking** - Only shows users online when the app is actively in use (page visible and active).
- Works with `current_user` from any auth system (Devise, custom, etc.).
- TTL-based presence in Redis, no tables required.
- **Automatic offline detection** when users close their browser/tab or switch to another tab.
- Uses Page Visibility API to detect when app is in background.
- Periodic heartbeats keep users online only when page is visible.
- Throttled Redis writes to reduce load (configurable).
- Safe SCAN-based counting; no `KEYS`.
- Configurable Redis client, TTL, throttle duration, user id method, controller accessor, and namespace.

## Installation
Add to your Gemfile:

```ruby
gem "whoisonline", github: "KapilDevPal/WhoIsOnline"
```

Or install directly:

```bash
bundle add whoisonline
```

## Quick Start
Create an initializer `config/initializers/whoisonline.rb`:

```ruby
WhoIsOnline.configure do |config|
  config.redis = -> { Redis.new(url: ENV.fetch("REDIS_URL")) }
  config.ttl = 90.seconds  # Users drop off after 90 seconds of inactivity
  config.throttle = 30.seconds  # Allow frequent updates for activity tracking
  config.user_id_method = :id
  config.activity_only = true  # Only track when app is actively in use (default: true)
  config.heartbeat_interval = 30.seconds  # Send heartbeat every 30 seconds when active
end
```

**Add the activity tracking script to your main layout** (e.g., `app/views/layouts/application.html.erb`):

```erb
<%= whoisonline_offline_script %>
```

This will:
- Track users as online only when the page is visible and active
- Send periodic heartbeats (every 30 seconds) to keep users online
- Automatically mark users offline when they switch tabs or close the browser
- Uses Page Visibility API to detect when app is in background

## Public API
- `WhoIsOnline.track(user)` – mark a user online (auto-called by the controller concern).
- `WhoIsOnline.offline(user)` – mark a user offline immediately.
- `WhoIsOnline.online?(user)` – boolean.
- `WhoIsOnline.count` – number of online users (via SCAN).
- `WhoIsOnline.user_ids` – array of ids (strings by default).
- `WhoIsOnline.users(User)` – ActiveRecord relation for convenience.

## Configuration
```ruby
WhoIsOnline.configure do |config|
  config.redis = -> { Redis.new(url: ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0")) }
  config.ttl = 90.seconds           # how long a user stays online without activity (default: 90s)
  config.throttle = 30.seconds     # minimum time between Redis writes per user (default: 30s)
  config.user_id_method = :id      # how to pull an ID from the user object
  config.current_user_method = :current_user # method on controllers
  config.namespace = "whoisonline:user"
  config.activity_only = true      # only track when app is actively in use (default: true)
  config.heartbeat_interval = 30.seconds  # heartbeat frequency when active (default: 30s)
  config.auto_hook = false         # disable controller auto-hook when using activity_only (default: false)
  config.logger = Rails.logger if defined?(Rails)
end
```

**Key Settings:**
- `activity_only = true` - Only shows users online when page is visible/active (recommended)
- `ttl = 90.seconds` - Users drop off quickly when inactive (shorter = more accurate)
- `heartbeat_interval = 30.seconds` - How often to send heartbeats when active
- `auto_hook = false` - Disabled by default when using activity tracking (set to `true` if you want both)

## Performance Notes
- Uses `SET key value EX ttl` for O(1) writes.
- Throttling prevents hot users from spamming Redis.
- Counting and user listing use `SCAN` to avoid blocking Redis (`KEYS` is not used).
- Namespace keeps presence keys isolated; use a dedicated Redis db/cluster for large scale.

## Example Usage in Rails
```ruby
# Somewhere in your controller you can also call manually:
WhoIsOnline.track(current_user)

# Mark user offline (e.g., on logout)
WhoIsOnline.offline(current_user)

# In a background job
if WhoIsOnline.online?(user)
  # notify
end

# In a dashboard
@online_users = WhoIsOnline.users(User).order(last_sign_in_at: :desc)
@online_count = WhoIsOnline.count
```

### Layout Example
In your main layout (`app/views/layouts/application.html.erb`):

```erb
<!DOCTYPE html>
<html>
  <head>
    <title>My App</title>
    <%= csrf_meta_tags %>
  </head>
  <body>
    <%= yield %>
    <%= whoisonline_offline_script %>
  </body>
</html>
```

## Extensibility
- Engine-based hook is easy to extend (e.g., add ActionCable broadcast).
- Tracker service is isolated and unit-testable.
- Configuration is thread-safe and lazy-instantiated.

## Author
- Kapil Dev Pal – dev.kapildevpal@gmail.com / @rails_to_rescue
- Project: rails_to_rescue


