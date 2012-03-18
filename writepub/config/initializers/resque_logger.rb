# Configure logging.
# We use various outputters, so require them, otherwise config chokes
require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/fileoutputter'
require 'log4r/outputter/datefileoutputter'
require 'log4r/outputter/emailoutputter'


cfg = Log4r::YamlConfigurator
cfg['RAILS_ROOT'] = Rails.root.to_s
cfg['RAILS_ENV']  = Rails.env

# load the YAML file with this
cfg.load_yaml_file File.expand_path("../../resque_log4r.yml",__FILE__)
Resque.class_eval do
  
  def logger
    Log4r::Logger['default']
  end

end

Resque.logger.level = (Rails.env == 'production' ? Log4r::INFO : Log4r::DEBUG )

if Rails.env == 'production'
  Log4r::Outputter['stderr'].level = Log4r::OFF
end

