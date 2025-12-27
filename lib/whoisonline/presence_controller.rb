require "action_controller"

module WhoIsOnline
  class PresenceController < ActionController::Base
    # Skip CSRF for sendBeacon requests (they may not include CSRF token reliably)
    skip_before_action :verify_authenticity_token, raise: false
    protect_from_forgery with: :null_session, only: [:offline]

    def offline
      user = resolve_whoisonline_user
      WhoIsOnline.offline(user) if user
      head :ok
    rescue StandardError => e
      WhoIsOnline.configuration.logger&.warn("whoisonline offline failed: #{e.class} #{e.message}")
      head :ok
    end

    def heartbeat
      user = resolve_whoisonline_user
      WhoIsOnline.track(user) if user
      head :ok
    rescue StandardError => e
      WhoIsOnline.configuration.logger&.warn("whoisonline heartbeat failed: #{e.class} #{e.message}")
      head :ok
    end

    private

    def resolve_whoisonline_user
      method = WhoIsOnline.configuration.current_user_method
      return public_send(method) if respond_to?(method, true)

      nil
    end
  end
end

