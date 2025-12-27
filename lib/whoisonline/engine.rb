require "rails/engine"
require_relative "controller"
require_relative "presence_controller"

module WhoIsOnline
  class Engine < ::Rails::Engine
    isolate_namespace WhoIsOnline

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
        include WhoIsOnline::ApplicationHelper
      end
    end
  end
end


