# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

DOMAIN_NAME = 'localhost:3000'
APP_ID = "172334986143428"
APP_SECRET = "ee6e0bec30ce02060fb57e6136f82fa3"
FACEBOOK_APP_NAME = "collegeswaptest"

AWS_S3_BUCKET_NAME = "collegeswaptest"
