# WhoIsOnline

Track “who is online right now?” in Rails 7/8 using Redis TTL. No database writes, production-safe, and auto-hooks into controllers via a Rails Engine.

## Features
- Rails Engine auto-includes a controller concern to mark users online.
- Works with `current_user` from any auth system (Devise, custom, etc.).
- TTL-based presence in Redis, no tables required.
- Throttled Redis writes to reduce load (configurable).
- Safe SCAN-based counting; no `KEYS`.
- Configurable Redis client, TTL, throttle duration, user id method, controller accessor, and namespace.

## Installation
Add to your Gemfile:

```ruby
gem "whoisonline", github: "rails-to-rescue/whoisonline"
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
  config.ttl = 5.minutes
  config.throttle = 60.seconds
  config.user_id_method = :id
end
```

The engine auto-adds a concern that runs after each controller action to mark the `current_user` as online. Nothing else is required.

## Public API
- `WhoIsOnline.track(user)` – mark a user online (auto-called by the controller concern).
- `WhoIsOnline.online?(user)` – boolean.
- `WhoIsOnline.count` – number of online users (via SCAN).
- `WhoIsOnline.user_ids` – array of ids (strings by default).
- `WhoIsOnline.users(User)` – ActiveRecord relation for convenience.

## Configuration
```ruby
WhoIsOnline.configure do |config|
  config.redis = -> { Redis.new(url: ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0")) }
  config.ttl = 5.minutes           # how long a user stays online without activity
  config.throttle = 60.seconds     # minimum time between Redis writes per user
  config.user_id_method = :id      # how to pull an ID from the user object
  config.current_user_method = :current_user # method on controllers
  config.namespace = "whoisonline:user"
  config.auto_hook = true          # disable if you prefer manual tracking
  config.logger = Rails.logger if defined?(Rails)
end
```

## Performance Notes
- Uses `SET key value EX ttl` for O(1) writes.
- Throttling prevents hot users from spamming Redis.
- Counting and user listing use `SCAN` to avoid blocking Redis (`KEYS` is not used).
- Namespace keeps presence keys isolated; use a dedicated Redis db/cluster for large scale.

## Example Usage in Rails
```ruby
# Somewhere in your controller you can also call manually:
WhoIsOnline.track(current_user)

# In a background job
if WhoIsOnline.online?(user)
  # notify
end

# In a dashboard
@online_users = WhoIsOnline.users(User).order(last_sign_in_at: :desc)
@online_count = WhoIsOnline.count
```

## Extensibility
- Engine-based hook is easy to extend (e.g., add ActionCable broadcast).
- Tracker service is isolated and unit-testable.
- Configuration is thread-safe and lazy-instantiated.

## Author
- Kapil Dev Pal – dev.kapildevpal@gmail.com / @rails_to_rescue
- Project: rails_to_rescue


