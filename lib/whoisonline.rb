require "active_support"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/module/delegation"

require_relative "whoisonline/version"
require_relative "whoisonline/configuration"
require_relative "whoisonline/redis_store"
require_relative "whoisonline/tracker"
require_relative "whoisonline/engine"

module WhoIsOnline
  class << self
    delegate :track, :online?, :count, :user_ids, :users, to: :tracker

    def tracker
      @_tracker ||= Tracker.new(configuration, redis_store)
    end

    def redis_store
      @_redis_store ||= RedisStore.new(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
      configuration
    end
  end
end

