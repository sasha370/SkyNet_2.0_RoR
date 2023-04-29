# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
require_relative '../app/bots/telegram_bot'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Load environment variables from .env file
# Only in development and test environments
Dotenv::Railtie.load if %w[development test].include? ENV['RAILS_ENV']

module SkyNet
  # SkyNet application
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.i18n.default_locale = :ru
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Do not start Telegram bot in Rails console or in test environment
    unless Rails.const_defined?('Rails::Console') || Rails.env.test?
      # Initialize Telegram bot only after Rails initialization
      # It uses separate thread to run in background
      config.after_initialize do
        Thread.new do
          bot = TelegramBot.new(ENV['TELEGRAM_BOT_TOKEN'])
          bot.run
        end
      end
    end
  end
end
