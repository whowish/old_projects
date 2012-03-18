class AdminApproveDiscussionController < ApplicationController
   layout 'valhalla'
  before_filter :check_admin
  def index
    
  end
  def approve
    discussion_list = params[:discussion_list]
    discussions_id = discussion_list.split(",")
    discussions_id = [] if discussion_list == ""
    
    discussions_id.each do |d_id|
      discussion = Discussion.first(:conditions=>{:id => d_id})
      next if !discussion
      discussion.status = Discussion::STATUS_ACTIVE
      discussion.save
      
      Feed.create_feed(discussion)
      

    end
    
    render :json=>{:ok=>true}
      
  end
  def disapprove
    discussion_list = params[:discussion_list]
    discussions_id = discussion_list.split(",")
    discussions_id = [] if discussion_list == ""
    
    discussions_id.each do |d_id|
      discussion = Discussion.first(:conditions=>{:id => d_id})
      next if !discussion
      discussion.status = Discussion::STATUS_DELETED
      discussion.save
      
      creator = Member.first(:conditions=>{:facebook_id=>discussion.creator_facebook_id})
      creator.add_credit(-POINT_ADD_FIGURE) if creator
    end
    
    render :json=>{:ok=>true}
  end
end
