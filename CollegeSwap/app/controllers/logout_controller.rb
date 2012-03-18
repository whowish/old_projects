class LogoutController < ApplicationController
  def index
    session[:access_token] = nil
    
    redirect_to "/"
  end
end
