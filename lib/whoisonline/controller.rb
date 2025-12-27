require "active_support/concern"

module WhoIsOnline
  module Controller
    extend ActiveSupport::Concern

    included do
      after_action :who_is_online_track_user
    end

    private

    def who_is_online_track_user
      return unless WhoIsOnline.configuration.auto_hook

      user = resolve_whoisonline_user
      return unless user

      WhoIsOnline.track(user)
    rescue StandardError => e
      WhoIsOnline.configuration.logger&.warn("whoisonline track failed: #{e.class} #{e.message}")
      true
    end

    def resolve_whoisonline_user
      method = WhoIsOnline.configuration.current_user_method
      return public_send(method) if respond_to?(method, true)

      nil
    end
  end
end
