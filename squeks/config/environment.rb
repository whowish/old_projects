# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

COMPACT_POLICY = "NOI COR PSA OUR IND OTC"

MUST_LOGIN_ERROR = "Must Login"
TOO_FEW_FRIENDS_ERROR = "Too few friends"
THRESHOLD_FRIENDS = 10

POINT_ADD_FIGURE = 10
POINT_ADD_IMAGE = 2
POINT_VOTE_IMAGE = 1
POINT_LOVE_FIGURE = 3
POINT_VOTE_COMMENT = 1
POINT_ADD_COMMENT = 1

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
  #config.logger = Logger.new(STDOUT)


  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end

require 'net/http'
require 'net/https'
require 'uri'

Net::HTTP.version_1_2


THUMBNAIL_SIZES = ["660x330","50x50","160x160"]
ENV['S3_ENABLED'] = "true"