require "concurrent/hash"

module WhoIsOnline
  class Tracker
    def initialize(configuration, redis_store)
      @configuration = configuration
      @redis_store = redis_store
      @last_write_by_user = Concurrent::Hash.new
    end

    def track(user)
      uid = extract_id(user)
      return unless uid
      return if throttled?(uid)

      key = presence_key(uid)
      now = Time.now.to_i
      result = @redis_store.write_presence(key, now, ttl_seconds)
      @last_write_by_user[uid] = Time.now if result
    end

    def offline(user)
      uid = extract_id(user)
      return unless uid

      key = presence_key(uid)
      @redis_store.delete_presence(key)
      @last_write_by_user.delete(uid)
    end

    def online?(user)
      uid = extract_id(user)
      return false unless uid

      @redis_store.exists?(presence_key(uid))
    end

    def count
      user_ids.size
    end

    def user_ids
      keys = @redis_store.scan_keys(match: "#{@configuration.namespace}:*")
      keys.lazy.map { |key| key.split(":").last }.to_a
    end

    def users(model_class)
      model_class.where(id: user_ids)
    end

    private

    def extract_id(user)
      return nil unless user
      return user if user.is_a?(String) || user.is_a?(Numeric)
      return user.public_send(@configuration.user_id_method) if user.respond_to?(@configuration.user_id_method)

      nil
    end

    def presence_key(uid)
      "#{@configuration.namespace}:#{uid}"
    end

    def ttl_seconds
      @configuration.ttl.to_i
    end

    def throttled?(uid)
      return false unless @configuration.throttle

      last = @last_write_by_user[uid]
      return false unless last

      (Time.now - last) < @configuration.throttle
    end
  end
end

