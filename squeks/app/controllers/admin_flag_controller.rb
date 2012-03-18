class AdminFlagController < ApplicationController
  
  layout "valhalla"
  
  before_filter :check_admin
  
  def index
    
  end
end
