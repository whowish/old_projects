class LogoutController < ApplicationController
  def index
    session[:access_token] = nil
    session[:facebook_data] = nil

    params[:redirect_url] = "http://"+DOMAIN_NAME if !params[:redirect_url] or params[:redirect_url].match("/logout")
    redirect_to params[:redirect_url]
  end
end
