require "logger"

module WhoIsOnline
  class Configuration
    DEFAULT_NAMESPACE = "whoisonline:user".freeze

    attr_accessor :ttl, :throttle, :user_id_method, :namespace, :auto_hook,
                  :logger, :current_user_method
    attr_writer :redis

    def initialize
      @ttl = 5.minutes
      @throttle = 60.seconds
      @user_id_method = :id
      @current_user_method = :current_user
      @namespace = DEFAULT_NAMESPACE
      @auto_hook = true
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


