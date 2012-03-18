require 'resque'
require 'yaml'

rails_env = ENV['RAILS_ENV'] || 'development'
 
yml = YAML.load_file File.expand_path("../../resque.yml",__FILE__)
config = yml[rails_env.downcase]

Resque.redis = Redis.new(:host => config['host'], :port => config['port'])
