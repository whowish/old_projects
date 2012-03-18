# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!

if ENV['STAGING']
  DOMAIN_NAME = 'squeks-staging.heroku.com'
  APP_ID = "204043839636066"
  APP_SECRET = "d2b3cade8e4a16a53b77a33694dee838"
  FACEBOOK_APP_NAME = "squeksstaging"

  AWS_S3_BUCKET_NAME = "squeksstaging"
else
  DOMAIN_NAME = 'www.squeks.com'
  APP_ID = "132211216851938"
  APP_SECRET = "39cb80beb66f02c987f37744e138a02f"
  FACEBOOK_APP_NAME = "mysqueks"

  AWS_S3_BUCKET_NAME = "squeks"
end
