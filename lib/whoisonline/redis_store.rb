require "redis"

module WhoIsOnline
  class RedisStore
    def initialize(configuration)
      @configuration = configuration
    end

    def connection
      @connection ||= @configuration.redis_connection
    end

    def write_presence(key, value, ttl_seconds)
      connection.set(key, value, ex: ttl_seconds)
    rescue StandardError => e
      log(:warn, "whoisonline write failed: #{e.class} #{e.message}")
      nil
    end

    def exists?(key)
      connection.exists?(key)
    rescue StandardError => e
      log(:warn, "whoisonline exists? failed: #{e.class} #{e.message}")
      false
    end

    def scan_keys(match:)
      return enum_for(:scan_keys, match: match) unless block_given?

      connection.scan_each(match: match) { |key| yield key }
    rescue StandardError => e
      log(:warn, "whoisonline scan failed: #{e.class} #{e.message}")
      []
    end

    private

    def log(level, message)
      logger = @configuration.logger
      return unless logger

      logger.public_send(level, message)
    end
  end
end


