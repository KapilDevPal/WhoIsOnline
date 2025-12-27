require "rails/engine"
require_relative "controller"

module WhoIsOnline
  class Engine < ::Rails::Engine
    isolate_namespace WhoIsOnline

    initializer "whoisonline.controller" do
      ActiveSupport.on_load(:action_controller) do
        include WhoIsOnline::Controller
      end
    end
  end
end


