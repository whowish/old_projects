require File.expand_path("../writepub_tag/base", __FILE__)
require File.expand_path("../preprocessing/base", __FILE__)

Dir[File.expand_path("../writepub_tag/**/*.rb", __FILE__)].each {|f| require f}
Dir[File.expand_path("../preprocessing/**/*.rb", __FILE__)].each {|f| require f}
