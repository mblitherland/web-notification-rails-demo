require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WebNotificationRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.vapid_public_key = "BHIGx9bAvOGx5x8eBCGQDLKPX7o-HYsxJnf9SMxmBOh6RtlrC-uZ2J9bLAoNkSVF6mtTc600-xgPkGa7Rlpt4wk="
    config.vapid_private_key = "7CDsnwhmZdXUwrrfUjP15V-8JGFpvqaG-yLdvcBHNAc="
  end
end
