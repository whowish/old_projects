require 'redis'
require 'yaml'
 
yml = YAML.load_file File.expand_path("../../redis.yml",__FILE__)
config = yml[Rails.env.to_s.downcase]

$redis = Redis.new(:host => config['host'], :port => config['port'])
