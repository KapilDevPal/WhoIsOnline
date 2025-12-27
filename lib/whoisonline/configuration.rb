require "logger"

module WhoIsOnline
  class Configuration
    DEFAULT_NAMESPACE = "whoisonline:user".freeze

    attr_accessor :ttl, :throttle, :user_id_method, :namespace, :auto_hook,
                  :logger, :current_user_method, :heartbeat_interval, :activity_only
    attr_writer :redis

    def initialize
      @ttl = 90.seconds  # Shorter TTL - users drop off quickly when inactive
      @throttle = 30.seconds  # Allow more frequent updates for activity tracking
      @user_id_method = :id
      @current_user_method = :current_user
      @namespace = DEFAULT_NAMESPACE
      @auto_hook = false  # Disable auto-hook - use heartbeat instead
      @heartbeat_interval = 30.seconds  # Send heartbeat every 30 seconds when active
      @activity_only = true  # Only track when app is actively in use
      @logger = default_logger
    end

    def redis
      @redis ||= lambda do
        Redis.new(url: ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0"))
      end
    end

    def redis_connection
      client = redis.respond_to?(:call) ? redis.call : redis
      raise ArgumentError, "config.redis must return a Redis-compatible client" unless client.respond_to?(:set)

      client
    end

    private

    def default_logger
      return Rails.logger if defined?(Rails)

      Logger.new($stdout, progname: "WhoIsOnline")
    end
  end
end


