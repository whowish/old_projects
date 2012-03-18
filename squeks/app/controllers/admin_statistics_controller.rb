class AdminStatisticsController < ApplicationController
  layout "valhalla"
  
  before_filter :check_admin
end
