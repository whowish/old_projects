class DiscussionController < ApplicationController
  include DiscussionHelper

  def index
    if $facebook.is_guest
      render :not_login
    end
  end
  
  def add
    if $facebook.is_guest
      pending = DiscussionPending.new
      pending.status = DiscussionPending::STATUS_PENDING
      pending.data = ActiveSupport::JSON.encode({:title=>params[:title],:description=>params[:description],:figure_list_id=>params[:figure_list_id],:is_anonymous=>(($is_anonymous==true)?"yes":"no")})
      pending.save
      
      render :json=>{:ok=>true,:redirect_url=>"https://www.facebook.com/dialog/oauth?client_id=#{APP_ID}&redirect_uri=#{CGI.escape('http://'+DOMAIN_NAME+'/discussion_pending/'+pending.unique_key)}"}  

      return
    end
    
    ok,discussion,error_message = inner_create(params[:title],params[:description],params[:figure_list_id])
    
    if ok
      render :json=>{:ok=>true,:credits=>$facebook.credits,:previous_credits=>$facebook[:previous_credits],:discussion_url=>"/discussion/view/#{discussion.id}"}
    else
      render :json=>{:ok=>false,:error_message=>error_message}
    end
  end
  
  def edit
    if $facebook.is_guest or !$facebook.is_aesir
      render :json=>{:ok=>false, :error_message=>MUST_LOGIN_ERROR}
      return
    end
    
    @discussion = Discussion.first(:conditions=>{:id => params[:discussion_id]})
    @discussion.title = params[:title]
    
    if @discussion.title == "" or @discussion.title == nil
      render :json=>{:ok=>false, :error_message=>"Title cannot be blank"}
      return
    end
    
    @discussion.description = params[:description]
    @discussion.update_discussion_figure(params[:figure_list_id])
   
    if !@discussion.save
      render :json=>{:ok=>false, :error_message=>format_error(@discussion.errors)}
      return
    end
    
    render :json=>{:ok=>true,:discussion_url=>"/discussion/view/#{@discussion.id}"}
  end
  
  def delete
    @discussion = Discussion.first(:conditions=>{:id => params[:discussion_id]})
    if !@discussion.active?
      render :json=>{:ok=>false,:error_message=>"This discussion is not valid anymore because it is deleted by admin."}
      return
    end
    
    @discussion.status = Discussion::STATUS_DELETED
    
    if !@discussion.save
      render :json=>{:ok=>false, :error_message=>format_error(@discussion.errors)}
      return
    end
    
    render :json=>{:ok=>true}
  end
  
  def view
    connection = ActiveRecord::Base.connection();
    @discussion = Discussion.first(:conditions=>{:id => params[:discussion_id]})
    
    if !@discussion
      render "discussion/not_found"
      return
    end
    
    if !@discussion.active?
      render "discussion/not_found"
      return
    end
    
    connection.execute("UPDATE `discussions` SET `views` = `views` + '1' WHERE `id`='"+ @discussion.id.to_s + "'")
  end
  
  def love

    if $facebook.is_guest
      pending = DiscussionLovePending.new
      pending.status = DiscussionLovePending::STATUS_PENDING
      pending.data = ActiveSupport::JSON.encode({:discussion_id=>params[:discussion_id],:type=>params[:type]})
      pending.save
      
      render :json=>{:ok=>true,:redirect_url=>"https://www.facebook.com/dialog/oauth?client_id=#{APP_ID}&redirect_uri=#{CGI.escape('http://'+DOMAIN_NAME+'/discussion_love_pending/'+pending.unique_key)}"}  

      return
    end
    
    ok,@discussion,error_message = inner_love(params[:discussion_id].strip,params[:type])

    if ok
      
      if params[:return_html_type] == "unit"
        render :json => {:ok=>true,
                      :html=>(render_to_string :partial=>"/discussion/discussion_unit", :locals=>{:discussion=>@discussion})
                  }
      elsif params[:return_html_type] == "pop_unit"
        render :json => {:ok=>true,
                      :html=>(render_to_string :partial=>"/discussion/discussion_popular_unit", :locals=>{:discussion=>@discussion})
                  }
      elsif params[:return_html_type] == "top_unit"
        render :json => {:ok=>true,
                      :html=>(render_to_string :partial=>"/home/top_discussion_unit", :locals=>{:entity=>@discussion})
                  }
      else
        render :json => {:ok=>true,
                      :love_meter=>(render_to_string :partial=>"/discussion/love_meter", :locals=>{:discussion=>@discussion})
                  }
      end
    else
      render :json =>{:ok=>false,:error_message=>error_message}
    end
  end
  
  def comment_index
    @discussion = Discussion.first(:conditions=>{:id => params[:discussion_id]})
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"/discussion/comment_panel",:locals=>{:discussion=>@discussion})}
  end

  def save_comment

    render :json=>{:ok=>false,:error_message=>MUST_LOGIN_ERROR} and return if $facebook.is_guest

    @discussion = Discussion.first(:conditions=>{:id => params[:discussion_id]})
    if !@discussion
      render :json => {:ok=>false,:error_message=>"discussion not found"}
      return
    end
    
    if !@discussion.active?
      render :json => {:ok=>false,:error_message=>"This discussion is not valid anymore because it is deleted by admin."}
      return
    end
    
    # check blocking word
    forbidden_words = WordFilter.get_forbidden_words(params[:comment])
    
    if forbidden_words.length > 0
      render :json => {:ok=>false,:error_message=>"Please avoid these words: #{forbidden_words.join(" ,")}"}
      return
    end
    
    #check duplicate
    count_duplicate = DiscussionComment.count(:conditions=>{:facebook_id=>$member.facebook_id, :discussion_id=>@discussion.id, :comment=>params[:comment].strip})
    
    if count_duplicate > 0
      render :json => {:ok=>false,:error_message=>"Your comment was previously submitted. Please reload the page to see it."}
      return
    end
    
    @comment = DiscussionComment.new
    @comment.facebook_id = $member.facebook_id
    @comment.is_anonymous = $is_anonymous
    @comment.discussion_id = @discussion.id
    @comment.comment = params[:comment].strip
    @comment.created_date = Time.now
    @comment.agrees = 0
    @comment.disagrees = 0
    @comment.total_agree = 0
    @comment.parent_id = 0
    @comment.status = DiscussionComment::STATUS_ACTIVE
   
    if !@comment.save
      render :json => {:ok=>false,:error_message=>"discussion comment error"}
      return
    end
    
    ActiveRecord::Base.connection.execute("UPDATE `discussions` SET `replies` = `replies` + '1' WHERE `id`='"+ @discussion.id.to_s + "'")
  
    #Feed.create_feed(@comment)
  
    render :json => {:ok=>true,:html=>(render_to_string :partial=>"/discussion/comment_view",:locals=>{:comment=>@comment,:show_sub_comment=>false})}
    
  end

  def save_sub_comment

    render :json=>{:ok=>false,:error_message=>MUST_LOGIN_ERROR} and return if $facebook.is_guest
    
    @parent_comment = DiscussionComment.first(:conditions=>{:id=>params[:parent_id]})
    
    if !@parent_comment
      render :json=>{:ok=>false,:error_message=>"The comment that you reply does not exist."}
      return
    end

    @comment = DiscussionComment.new
    @comment.facebook_id = $member.facebook_id
    @comment.is_anonymous = $is_anonymous
    @comment.discussion_id = @parent_comment.discussion_id
    @comment.comment = params[:comment]
    @comment.created_date = Time.now
    @comment.agrees = 0
    @comment.disagrees = 0
    @comment.parent_id = params[:parent_id]
    @comment.status = Comment::STATUS_ACTIVE

    if !@comment.save
      render :json => {:ok=>false,:error_message=>"comment error"}
      return
    end
    
    #Feed.create_feed(@comment)
    #Notification.notify(@comment)
    #$facebook.add_credit(POINT_ADD_COMMENT)

    render :json => {:ok=>true,:html=>(render_to_string :partial=>"/discussion/sub_comment",:locals=>{:comment=>@comment})}

  end

  def agree

    render :json=>{:ok=>false,:error_message=>MUST_LOGIN_ERROR} \
      and return if $facebook.is_guest

    @comment = DiscussionComment.first(:conditions=>{:id => params[:comment_id]})

    render :json=>{:ok=>false,:error_message=>"The comment does not exist."}\
      and return if !@comment
    
    

    Lock.generate("DiscussionComment",$member.facebook_id,@comment.id).synchronize {
      @comment_agree = DiscussionCommentAgree.first(:conditions=>{:discussion_comment_id=>@comment.id,:facebook_id=>$member.facebook_id})

      if !@comment_agree
        @comment_agree = DiscussionCommentAgree.new
        @comment_agree.discussion_comment_id = @comment.id
        @comment_agree.facebook_id = $member.facebook_id
        
        if params[:type] != DiscussionCommentAgree::TYPE_CANCEL
          ActiveRecord::Base.connection.execute("UPDATE `discussion_comments` SET `total_agree` = `total_agree` + '1' WHERE `id`='"+ @comment.id.to_s + "'")
          if @comment.parent_id != 0
            ActiveRecord::Base.connection.execute("UPDATE `discussion_comments` SET `total_agree` = `total_agree` + '1' WHERE `id`='"+ @comment.parent_id.to_s + "'")
          end
        end
      end

      @comment_agree.is_anonymous = $is_anonymous

      if @comment_agree.agree_type == params[:type]
        @comment_agree.save
        render :json => {:ok=>true,:agree_button=>(render_to_string :partial=>"/discussion/comment_status",:locals=>{:comment=>@comment})}
        return
      end
      
      if @comment_agree.agree_type == DiscussionCommentAgree::TYPE_AGREE
        ActiveRecord::Base.connection.execute("UPDATE `discussion_comments` SET `agrees` = `agrees` - '1' WHERE `id`='"+ @comment.id.to_s + "'")
      elsif @comment_agree.agree_type == DiscussionCommentAgree::TYPE_DISAGREE
        ActiveRecord::Base.connection.execute("UPDATE `discussion_comments` SET `disagrees` = `disagrees` - '1' WHERE `id`='"+ @comment.id.to_s + "'")
      end

      if params[:type] == DiscussionCommentAgree::TYPE_AGREE
        ActiveRecord::Base.connection.execute("UPDATE `discussion_comments` SET `agrees` = `agrees` + '1' WHERE `id`='"+ @comment.id.to_s + "'")
      elsif params[:type] == DiscussionCommentAgree::TYPE_DISAGREE
        ActiveRecord::Base.connection.execute("UPDATE `discussion_comments` SET `disagrees` = `disagrees` + '1' WHERE `id`='"+ @comment.id.to_s + "'")
      end

      @comment_agree.agree_type = params[:type]

      if params[:type] != DiscussionCommentAgree::TYPE_CANCEL
        @comment_agree.created_date = Time.now
#        $facebook.add_credit(POINT_VOTE_COMMENT)
      else
         ActiveRecord::Base.connection.execute("UPDATE `discussion_comments` SET `total_agree` = `total_agree` - '1' WHERE `id`='"+ @comment.id.to_s + "'")
         if @comment.parent_id != 0
           ActiveRecord::Base.connection.execute("UPDATE `discussion_comments` SET `total_agree` = `total_agree` - '1' WHERE `id`='"+ @comment.parent_id.to_s + "'")
       end
       
#       $facebook.add_credit(-POINT_VOTE_COMMENT)
      end

      @comment_agree.save
      
      #Feed.create_feed(@comment_agree) if @comment_agree.agree_type != CommentAgree::TYPE_CANCEL
      #Notification.notify(@comment_agree) if @comment_agree.agree_type != CommentAgree::TYPE_CANCEL
    }

    @comment = DiscussionComment.first(:conditions=>{:id => params[:comment_id]})

    partial_name = "/discussion/comment_status"
    partial_name = "/discussion/sub_comment_status" if @comment.parent_id > 0

    render :json => {:ok=>true,:agree_button=>(render_to_string :partial=>partial_name,:locals=>{:comment=>@comment})}
  end
 
  def delete_comment
    @comment = DiscussionComment.first(:conditions=>{:id=>params[:comment_id]})
    
    if @comment and @comment.status == DiscussionComment::STATUS_ACTIVE and ($facebook.is_aesir or @comment.facebook_id == $facebook.facebook_id)
      @comment.status = Comment::STATUS_DELETED
      @comment.save
    end
    
    render :json => {:ok=>true}
  end
  
  def share_discussion_comment
      @comment = DiscussionComment.first(:conditions=>{:id => params[:comment_id]})
      
      scope = []
      scope += [FacebookCache::SCOPE_PUBLISH_STREAM]
      result = $facebook.publish_comment(@comment,params[:message])
      
      if result[:ok] == false and result[:error_id] == FacebookCache::ERROR_NO_PERMISSION
    
        ticket = ShareTicket.create(:permission=>scope.join(','),
                                    :created_date=>Time.now,
                                    :finished_date=>nil,
                                    :status=>ShareTicket::STATUS_PENDING,
                                    :error_message=>"",
                                    :ref=>params[:message]) 
        
        return_url = "http://#{DOMAIN_NAME}/discussion/share_after_allow/#{@comment.id}/#{ticket.unique_key}"
        redirect_url = generate_permission_url(scope,return_url)
        
        render :json=>{:ok=>true,:comment_id=>@comment.id,:redirect_url=>redirect_url}
      else
         ticket = ShareTicket.create(:permission=>scope.join(','),
                                    :created_date=>Time.now,
                                    :finished_date=>nil,
                                    :status=>ShareTicket::STATUS_COMPLETED,
                                    :error_message=>"",
                                    :ref=>params[:message]) 
                                    
        render :json=>{:ok=>true}
      end
   end
   
   def share_after_allow
      @comment = DiscussionComment.first(:conditions=>{:id => params[:comment_id]})
      ticket = ShareTicket.first(:conditions=>{:unique_key=>params[:share_unique_key]})
      
      if ticket and ticket.status == ShareTicket::STATUS_PENDING
  
        result = $facebook.publish_discussion_comment(@comment,ticket.ref)
   
        if result[:ok] == true
          ticket.status = ShareTicket::STATUS_COMPLETED
        else
          ticket.status = ShareTicket::STATUS_ERROR
          ticket.error_message = result[:error_message] if result[:error_message]
        end
        
        ticket.finished_date = Time.now
        
        ticket.save
      end
      
      @discussion = Discussion.first(:conditions=>{:id=>@comment.discussion_id})
       
      redirect_to "/discussion/view/#{@comment.discussion_id}"
     
  end
 
  def share_discussion
    
    result = {}
    scope = []
    @discussion = Discussion.first(:conditions=>{:id => params[:discussion_id]})
    if $facebook.is_guest
      
      result[:ok] = false
      result[:error_id] = FacebookCache::ERROR_NO_PERMISSION
      
    else
      
      
      scope += [FacebookCache::SCOPE_PUBLISH_STREAM]
      result = $facebook.publish_discussion(@discussion,params[:message])
      
    end
    
    if result[:ok] == false and result[:error_id] == FacebookCache::ERROR_NO_PERMISSION
  
      ticket = ShareTicket.create(:permission=>scope.join(','),
                                  :created_date=>Time.now,
                                  :finished_date=>nil,
                                  :status=>ShareTicket::STATUS_PENDING,
                                  :error_message=>"",
                                  :ref=>params[:message]) 
      
      return_url = "http://"+DOMAIN_NAME+"/discussion/share_discussion_after_add/"+@discussion.id.to_s+"/"+ticket.unique_key
      redirect_url = generate_permission_url(scope,return_url)
      
      render :json=>{:ok=>true,:discussion_id=>@discussion.id,:redirect_url=>redirect_url}
      return
    else
      ticket = ShareTicket.create(:permission=>scope.join(','),
                                  :created_date=>Time.now,
                                  :finished_date=>nil,
                                  :status=>ShareTicket::STATUS_COMPLETED,
                                  :error_message=>"",
                                  :ref=>params[:message]) 
                                  
      render :json=>{:ok=>true}
    end
     
  end
 
  def share_discussion_after_add
   
    @discussion = Discussion.first(:conditions=>{:id => params[:discussion_id]})
    
    ticket = ShareTicket.first(:conditions=>{:unique_key=>params[:share_unique_key]})
    
    if ticket and ticket.status == ShareTicket::STATUS_PENDING

      result = $facebook.publish_discussion(@discussion,ticket.ref)
 
      if result[:ok] == true
        ticket.status = ShareTicket::STATUS_COMPLETED
      else
        ticket.status = ShareTicket::STATUS_ERROR
        ticket.error_message = result[:error_message] if result[:error_message]
      end
      
      ticket.finished_date = Time.now
      
      ticket.save
    end
     
    redirect_to   "/discussion/view/#{@discussion.id}"
   
 end
 
 def view_all
    @figure = Figure.first(:conditions=>{:id => params[:figure_id]})
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"/discussion/view_all",:locals=>{:figure=>@figure})}
 end
 

end
