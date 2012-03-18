# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

COMPACT_POLICY = "NOI COR PSA OUR IND OTC"

MUST_LOGIN_ERROR = "Must Login"

PAYPAL_TEST = false

if PAYPAL_TEST
  PAYPAL_REDIRECT_URL = "https://www.sandbox.paypal.com/webscr"
  PAYPAL_IPN_VERIFICATION_URL = "https://www.sandbox.paypal.com/cgi-bin/webscr"
  PAYPAL_IPN_URL = "http://www.friendmage.com/paypal_ipn"
  PAYPAL_REQUEST_PAY_KEY_URL = "https://svcs.sandbox.paypal.com/AdaptivePayments/Pay"
  PAYPAL_PAYMENT_DETAIL_URL = "https://svcs.sandbox.paypal.com/AdaptivePayments/PaymentDetails"
  
  PAYPAL_API_USERNAME = "tanin4_1266099950_biz_api1.gmail.com"
  PAYPAL_API_PASSWORD = "1266099956"
  PAYPAL_API_SIGNATURE = "AOGp908MTPfZOTwx64dvpnJhmHGhASV4kUXUqrq-blZfWda8hUPUaa4p"
  PAYPAL_API_APP_ID = "APP-80W284485P519543T"
  
  PAYPAL_RECEIVER = "seller_1266523729_biz@gmail.com"
else
  PAYPAL_REDIRECT_URL = "https://www.paypal.com/webscr"
  PAYPAL_IPN_VERIFICATION_URL = "https://www.paypal.com/cgi-bin/webscr"
  PAYPAL_IPN_URL = "http://www.friendmage.com/paypal_ipn"
  PAYPAL_REQUEST_PAY_KEY_URL = "https://svcs.paypal.com/AdaptivePayments/Pay"
  PAYPAL_PAYMENT_DETAIL_URL = "https://svcs.paypal.com/AdaptivePayments/PaymentDetails"
  
  PAYPAL_API_USERNAME = "mootoo.meepo_api1.gmail.com"
  PAYPAL_API_PASSWORD = "L7TXSN22WUE4P3YK"
  PAYPAL_API_SIGNATURE = "AFcWxV21C7fd0v3bYYYRCpSSRl31AB-MLcq.b7A56RvFSUJ1bBQ-g08l"
  PAYPAL_API_APP_ID = "APP-13267408E5370183F"
  
  PAYPAL_RECEIVER = "mootoo.meepo@gmail.com"
end

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require File.expand_path(File.dirname(__FILE__) + "/logger")

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end

require "smtp_tls"

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => 587,
  :authentication => :login,
  :user_name => "whowish@gmail.com",
  :password => 'whowish123',
  :tls => true
}

# disable logging
class ActiveRecord::ConnectionAdapters::AbstractAdapter
  def log_info(*args); end
end
