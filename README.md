# WhoIsOnline 💚

<div align="center">

![WhoIsOnline](https://img.shields.io/badge/WhoIsOnline-v0.1.3-brightgreen)
![Rails](https://img.shields.io/badge/Rails-7%2B-red)
![Ruby](https://img.shields.io/badge/Ruby-3.1%2B-red)
![License](https://img.shields.io/badge/License-MIT-blue)
![Gem](https://img.shields.io/gem/v/whoisonline?color=blue)

**Track "who is online right now?" in Rails using Redis TTL. Zero database writes, production-ready, and auto-hooks into controllers.**

[Installation](#-installation) • [Quick Start](#-quick-start) • [Configuration](#-configuration) • [API](#-public-api) • [Examples](#-examples)

</div>

---

## ✨ Features

- 🚀 **Zero Setup** - Rails Engine auto-includes controller concern
- 🔌 **Works with Any Auth** - Devise, custom, or any `current_user` method
- ⚡ **Redis TTL-Based** - No database tables required
- 👁️ **Smart Tracking** - Only tracks when tab is visible/active
- 🔄 **Automatic Offline Detection** - Marks users offline when browser closes
- ⏱️ **Throttled Writes** - Configurable to reduce Redis load
- 🔍 **SCAN-Based** - Safe counting without blocking Redis (`KEYS` not used)
- 🎛️ **Highly Configurable** - Redis client, TTL, throttle, heartbeat interval, and more

---

## 📦 Installation

### From RubyGems (Recommended)

Add to your `Gemfile`:

```ruby
gem "whoisonline"
```

Then run:

```bash
bundle install
```

### From GitHub (Development)

```ruby
gem "whoisonline", github: "KapilDevPal/WhoIsOnline"
```

---

## 🚀 Quick Start

### 1. Create Initializer

Create `config/initializers/whoisonline.rb`:

```ruby
WhoIsOnline.configure do |config|
  config.redis = -> { Redis.new(url: ENV.fetch("REDIS_URL")) }
  config.ttl = 5.minutes
  config.throttle = 60.seconds
  config.heartbeat_interval = 60.seconds # Heartbeat when tab is visible
end
```

### 2. Add to Layout (Optional but Recommended)

Add to your main layout (`app/views/layouts/application.html.erb`):

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

**That's it!** The engine automatically tracks users online after each controller action.

---

## 📖 Public API

```ruby
# Mark user online (auto-called by controller concern)
WhoIsOnline.track(user)

# Mark user offline immediately
WhoIsOnline.offline(user)

# Check if user is online
WhoIsOnline.online?(user)  # => true/false

# Get count of online users
WhoIsOnline.count  # => 42

# Get array of online user IDs
WhoIsOnline.user_ids  # => ["1", "2", "3"]

# Get ActiveRecord relation of online users
WhoIsOnline.users(User)  # => User.where(id: [...])
```

---

## ⚙️ Configuration

```ruby
WhoIsOnline.configure do |config|
  # Redis connection (required)
  config.redis = -> { Redis.new(url: ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0")) }
  
  # TTL settings
  config.ttl = 5.minutes                    # How long user stays online without activity
  config.throttle = 60.seconds              # Minimum time between Redis writes per user
  
  # User identification
  config.user_id_method = :id               # Method to get user ID
  config.current_user_method = :current_user # Method on controllers to get user
  
  # Heartbeat (for visible tab tracking)
  config.heartbeat_interval = 60.seconds    # Heartbeat frequency when tab is visible
  
  # Advanced
  config.namespace = "whoisonline:user"     # Redis key namespace
  config.auto_hook = true                   # Auto-include controller concern
  config.logger = Rails.logger             # Logger instance
end
```

### Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `ttl` | `5.minutes` | How long a user stays online without activity |
| `throttle` | `60.seconds` | Minimum time between Redis writes per user |
| `heartbeat_interval` | `60.seconds` | Heartbeat frequency when tab is visible |
| `user_id_method` | `:id` | Method to extract ID from user object |
| `current_user_method` | `:current_user` | Method name on controllers |
| `namespace` | `"whoisonline:user"` | Redis key namespace prefix |
| `auto_hook` | `true` | Auto-include controller concern |
| `logger` | `Rails.logger` | Logger for errors/warnings |

---

## 💡 Examples

### Basic Usage

```ruby
# In a controller (automatic via engine)
# Users are tracked after each action

# Check if user is online
if WhoIsOnline.online?(current_user)
  # User is currently online
end

# Get online users count
@online_count = WhoIsOnline.count

# Get online users
@online_users = WhoIsOnline.users(User)
```

### Manual Tracking

```ruby
# Manually mark user online
WhoIsOnline.track(current_user)

# Manually mark user offline (e.g., on logout)
WhoIsOnline.offline(current_user)
```

### In Background Jobs

```ruby
class NotificationJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)
    
    if WhoIsOnline.online?(user)
      # Only notify if user is online
      NotificationService.deliver(user)
    end
  end
end
```

### Dashboard View

```ruby
# In your controller
class DashboardController < ApplicationController
  def index
    @online_count = WhoIsOnline.count
    @online_users = WhoIsOnline.users(User)
                              .order(last_sign_in_at: :desc)
                              .limit(50)
  end
end
```

```erb
<!-- In your view -->
<div class="online-users">
  <h2>Online Now (<%= @online_count %>)</h2>
  <ul>
    <% @online_users.each do |user| %>
      <li><%= user.name %> <span class="badge">●</span></li>
    <% end %>
  </ul>
</div>
```

---

## 🎯 How It Works

1. **Controller Action** - After each action, the engine automatically calls `WhoIsOnline.track(current_user)`
2. **Redis Write** - User presence is stored in Redis with TTL: `SET whoisonline:user:123 <timestamp> EX 300`
3. **Throttling** - Writes are throttled per user to prevent Redis spam
4. **Heartbeat** - When tab is visible, JavaScript sends periodic heartbeats to keep user online
5. **Offline Detection** - When browser closes, JavaScript sends offline request
6. **TTL Expiry** - If no activity, Redis key expires automatically

---

## ⚡ Performance

- **O(1) Writes** - Uses `SET key value EX ttl` for constant-time operations
- **Throttled** - Prevents hot users from spamming Redis
- **SCAN-Based** - Counting uses `SCAN` instead of `KEYS` (non-blocking)
- **Namespace Isolation** - Keys are namespaced for easy management
- **No Database** - Zero database writes, all in Redis

### Recommended Settings

For **high-traffic** applications:

```ruby
config.ttl = 2.minutes              # Shorter TTL = more accurate
config.throttle = 30.seconds         # More frequent updates
config.heartbeat_interval = 30.seconds # More frequent heartbeats
```

For **low-traffic** applications:

```ruby
config.ttl = 10.minutes              # Longer TTL = less Redis activity
config.throttle = 120.seconds        # Less frequent updates
config.heartbeat_interval = 120.seconds # Less frequent heartbeats
```

---

## 🔧 Troubleshooting

### Users Not Showing as Online

1. Check Redis connection: `redis-cli ping`
2. Verify `current_user` method exists in your controllers
3. Check logs for errors: `tail -f log/development.log`
4. Verify TTL hasn't expired: `redis-cli TTL whoisonline:user:1`

### Helper Not Available

If `whoisonline_offline_script` is not available:

1. Restart Rails server
2. Check that gem is loaded: `bundle list | grep whoisonline`
3. Verify engine is loaded: Check `config/application.rb` for engine loading

### Heartbeat Not Working

1. Check browser console for JavaScript errors
2. Verify CSRF token is present: `<%= csrf_meta_tags %>`
3. Check network tab for heartbeat requests
4. Verify `heartbeat_interval` is configured

---

## 🛠️ Extensibility

The gem is designed to be extensible:

- **ActionCable Integration** - Broadcast presence changes
- **Custom Events** - Hook into track/offline events
- **Multiple Redis Instances** - Use different Redis for presence
- **Custom User Models** - Works with any user model structure

Example: ActionCable Integration

```ruby
# In an initializer
WhoIsOnline.tracker.define_singleton_method(:track) do |user|
  super(user)
  ActionCable.server.broadcast("presence", { user_id: user.id, status: "online" })
end
```

---

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Kapil Dev Pal**

- 📧 Email: dev.kapildevpal@gmail.com
- 🐦 Twitter: [@rails_to_rescue](https://twitter.com/rails_to_rescue)
- 🚀 Project: [rails_to_rescue](https://github.com/rails-to-rescue)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## ⭐ Show Your Support

If you find this gem useful, please give it a ⭐ on GitHub!

---

<div align="center">

**Made with ❤️ for the Rails community**

[Report Bug](https://github.com/KapilDevPal/WhoIsOnline/issues) • [Request Feature](https://github.com/KapilDevPal/WhoIsOnline/issues) • [View on GitHub](https://github.com/KapilDevPal/WhoIsOnline)

</div>
