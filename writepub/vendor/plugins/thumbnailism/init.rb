require File.dirname(__FILE__)+"/config"

require File.dirname(__FILE__)+"/#{THUMBNAILISM_DATABASE_ENGINE}/db_migration"
require File.dirname(__FILE__)+"/#{THUMBNAILISM_DATABASE_ENGINE}/temporary_file"

Dir[File.expand_path("../lib/**/*.rb", __FILE__)].each { |f| require f}