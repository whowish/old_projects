require 'yaml'
 
yml = YAML.load_file File.expand_path("../../sunspot.yml",__FILE__)
config = yml[Rails.env.to_s.downcase]

Sunspot.config.solr.url = config['url']


