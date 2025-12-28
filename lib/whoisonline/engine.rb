require "rails/engine"
require_relative "controller"
require_relative "presence_controller"

module WhoIsOnline
  class Engine < ::Rails::Engine
    isolate_namespace WhoIsOnline

    # Load helper before initializers run (for Zeitwerk compatibility)
    config.to_prepare do
      helper_path = File.expand_path("../../app/helpers/whoisonline/application_helper", __FILE__)
      require helper_path if File.exist?(helper_path)
    end

    initializer "whoisonline.controller" do
      ActiveSupport.on_load(:action_controller) do
        include WhoIsOnline::Controller
      end
    end

    initializer "whoisonline.routes" do |app|
      app.routes.append do
        post "/whoisonline/offline", to: "whoisonline/presence#offline", as: :whoisonline_offline
        post "/whoisonline/heartbeat", to: "whoisonline/presence#heartbeat", as: :whoisonline_heartbeat
      end
    end

    initializer "whoisonline.helpers" do
      ActiveSupport.on_load(:action_view) do
        # Helper should already be loaded via config.to_prepare
        if defined?(WhoIsOnline::ApplicationHelper)
          include WhoIsOnline::ApplicationHelper
        end
      end
    end
  end
end


