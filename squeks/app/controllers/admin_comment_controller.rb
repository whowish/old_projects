class AdminCommentController < ApplicationController
  layout "valhalla"
  
  before_filter :check_admin
end
