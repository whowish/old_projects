mongoid_conf = YAML::load_file(Rails.root.join('config/mongoid.yml'))[Rails.env]

logger = ((mongoid_conf['logger']==true) ? (Rails.logger) : (nil) )

Mongoid.configure do |config|
  
  config.master = Mongo::Connection.new(mongoid_conf['host'],
                                         mongoid_conf['port'],
                                         :logger => logger
                                         ).db(mongoid_conf['database'])
  
  if mongoid_conf['username'] and mongoid_conf['password']
    config.master.authenticate(mongoid_conf['username'], mongoid_conf['password'])
  end 
  
  config.autocreate_indexes = mongoid_conf['autocreate_indexes']
  
end
