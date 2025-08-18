require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)
require "tailwindcss"

module DummyRailsApp
  class Application < Rails::Application
    config.load_defaults 7.0
    config.eager_load = false
    
    # Configure ActionCable
    config.action_cable.mount_path = "/cable"
    config.action_cable.url = "ws://localhost:3000/cable"
    
    # Silence deprecation warnings in tests
    config.active_support.deprecation = :silence
  end
end