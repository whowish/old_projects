class ValhallaController < ApplicationController
  layout "valhalla"
  before_filter :check_aesir
  
end
