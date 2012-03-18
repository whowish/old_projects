require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/fileoutputter'
require 'log4r/outputter/datefileoutputter'
require 'log4r/outputter/emailoutputter'

cfg = Log4r::YamlConfigurator
cfg['RAILS_ROOT'] = Rails.root.to_s
cfg['RAILS_ENV']  = Rails.env

cfg.load_yaml_file("#{Rails.root.to_s}/config/log4r.yml")
Rails.logger = Log4r::Logger[Rails.env]