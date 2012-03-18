class ShareOptionController < ApplicationController

  def index

  end

  def save
    render :json=>{:ok=>false,:error_message=>"You are not logged in."} and return if $facebook.is_guest

    $facebook.is_anonymous = (params[:is_anonymous]=="yes")?true:false
    $facebook.is_share_love = (params[:share_love]=="yes")?true:false
    $facebook.is_share_hate = (params[:share_hate]=="yes")?true:false
    $facebook.is_share_comment = (params[:share_comment]=="yes")?true:false
    $facebook.is_share_comment_agree = (params[:share_comment_agree]=="yes")?true:false
    $facebook.is_share_comment_disagree = (params[:share_comment_disagree]=="yes")?true:false
    $facebook.save

    render :json=>{:ok=>true}
  end
end
