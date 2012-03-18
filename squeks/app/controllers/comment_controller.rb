class CommentController < ApplicationController
  include CommentHelper

  def index
    @figure = Figure.first(:conditions=>{:id => params[:figure_id]})
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"comment_panel",:locals=>{:figure=>@figure})}
  end
  
  def save_comment_after_login
    
  end

  def save_comment

    
    @figure = Figure.first(:conditions=>{:id => params[:figure_id]})
    if !@figure
      render :json => {:ok=>false,:error_message=>"figure not found"}
      return
    end

    if !@figure.active?
      render :json => {:ok=>false,:error_message=>"This figure is not valid anymore because it is deleted by admin."}
      return
    end
    
    # check blocking word
    forbidden_words = WordFilter.get_forbidden_words(params[:comment])
    
    if forbidden_words.length > 0
      render :json => {:ok=>false,:error_message=>"Please avoid these words: #{forbidden_words.join(" ,")}"}
      return
    end
    
    if $facebook.is_guest
      
      pending = CommentPending.new
      pending.status = CommentPending::STATUS_PENDING
      pending.data = ActiveSupport::JSON.encode({:type=>"comment",:comment=>params[:comment].strip,:figure_id=>@figure.id})
      pending.save
      
      render :json=>{:ok=>true,:redirect_url=>"https://www.facebook.com/dialog/oauth?client_id=#{APP_ID}&redirect_uri=#{CGI.escape('http://'+DOMAIN_NAME+'/comment_pending/'+pending.unique_key)}"}  

      return
    end
    
    ok,comment_obj,error_message = inner_save_comment(params[:comment],@figure)

    if ok
      render :json => {:ok=>true,:credits=>$facebook.credits,:previous_credits=>$facebook[:previous_credits],:html=>(render_to_string :partial=>"comment_view",:locals=>{:comment=>comment_obj,:show_sub_comment=>false})}
    else
      render :json => {:ok=>false,:error_message=>error_message}
    end
  end

  def save_sub_comment

    if $facebook.is_guest
      pending = CommentPending.new
      pending.status = CommentPending::STATUS_PENDING
      pending.data = ActiveSupport::JSON.encode({:type=>"sub_comment",:comment=>params[:comment].strip,:parent_id=>params[:parent_id]})
      pending.save
      
      render :json=>{:ok=>true,:redirect_url=>"https://www.facebook.com/dialog/oauth?client_id=#{APP_ID}&redirect_uri=#{CGI.escape('http://'+DOMAIN_NAME+'/comment_pending/'+pending.unique_key)}"}  

      return
    end
    
    ok,comment_obj,error_message = inner_save_sub_comment(params[:comment],params[:parent_id])

    if ok
      render :json => {:ok=>true,:credits=>$facebook.credits,:previous_credits=>$facebook[:previous_credits],:html=>(render_to_string :partial=>"sub_comment",:locals=>{:comment=>comment_obj,:show_sub_comment=>false})}
    else
      render :json => {:ok=>false,:error_message=>error_message}
    end
    
  end

  def agree

    render :json=>{:ok=>false,:error_message=>MUST_LOGIN_ERROR} \
      and return if $facebook.is_guest

    @comment = Comment.first(:conditions=>{:id => params[:comment_id]})

    render :json=>{:ok=>false,:error_message=>"The comment does not exist."}\
      and return if !@comment
    
    

    Lock.generate("Comment",$member.facebook_id,@comment.id).synchronize {
      @comment_agree = CommentAgree.first(:conditions=>{:comment_id=>@comment.id,:facebook_id=>$member.facebook_id})

      if !@comment_agree
        @comment_agree = CommentAgree.new
        @comment_agree.comment_id = @comment.id
        @comment_agree.facebook_id = $member.facebook_id
        
        if params[:type] != CommentAgree::TYPE_CANCEL
          ActiveRecord::Base.connection.execute("UPDATE `comments` SET `total_agree` = `total_agree` + '1' WHERE `id`='"+ @comment.id.to_s + "'")
          if @comment.parent_id != 0
            ActiveRecord::Base.connection.execute("UPDATE `comments` SET `total_agree` = `total_agree` + '1' WHERE `id`='"+ @comment.parent_id.to_s + "'")
          end
        end
      end

      @comment_agree.is_anonymous = $is_anonymous

      if @comment_agree.agree_type == params[:type]
        @comment_agree.save
        render :json => {:ok=>true,:agree_button=>(render_to_string :partial=>"comment_status",:locals=>{:comment=>@comment})}
        return
      end
      
      

      if @comment_agree.agree_type == CommentAgree::TYPE_AGREE
        ActiveRecord::Base.connection.execute("UPDATE `comments` SET `agrees` = `agrees` - '1' WHERE `id`='"+ @comment.id.to_s + "'")
      elsif @comment_agree.agree_type == CommentAgree::TYPE_DISAGREE
        ActiveRecord::Base.connection.execute("UPDATE `comments` SET `disagrees` = `disagrees` - '1' WHERE `id`='"+ @comment.id.to_s + "'")
      end

      if params[:type] == CommentAgree::TYPE_AGREE
        ActiveRecord::Base.connection.execute("UPDATE `comments` SET `agrees` = `agrees` + '1' WHERE `id`='"+ @comment.id.to_s + "'")
      elsif params[:type] == CommentAgree::TYPE_DISAGREE
        ActiveRecord::Base.connection.execute("UPDATE `comments` SET `disagrees` = `disagrees` + '1' WHERE `id`='"+ @comment.id.to_s + "'")
      end

      @comment_agree.agree_type = params[:type]

      if params[:type] != CommentAgree::TYPE_CANCEL
        @comment_agree.created_date = Time.now
#        $facebook.add_credit(POINT_VOTE_COMMENT)
      else
         ActiveRecord::Base.connection.execute("UPDATE `comments` SET `total_agree` = `total_agree` - '1' WHERE `id`='"+ @comment.id.to_s + "'")
         if @comment.parent_id != 0
           ActiveRecord::Base.connection.execute("UPDATE `comments` SET `total_agree` = `total_agree` - '1' WHERE `id`='"+ @comment.parent_id.to_s + "'")
       end
       
#       $facebook.add_credit(-POINT_VOTE_COMMENT)
      end

      @comment_agree.save
      
      Feed.create_feed(@comment_agree) if @comment_agree.agree_type != CommentAgree::TYPE_CANCEL
      Notification.notify(@comment_agree) if @comment_agree.agree_type != CommentAgree::TYPE_CANCEL
    }

    @comment = Comment.first(:conditions=>{:id => params[:comment_id]})

    partial_name = "comment_status"
    partial_name = "sub_comment_status" if @comment.parent_id > 0

    render :json => {:ok=>true,:credits=>$facebook.credits,:previous_credits=>$facebook[:previous_credits],:agree_button=>(render_to_string :partial=>partial_name,:locals=>{:comment=>@comment})}
  end
 
  def delete
    @comment = Comment.first(:conditions=>{:id=>params[:comment_id]})
    
    if @comment and @comment.status == Comment::STATUS_ACTIVE and ($facebook.is_aesir or @comment.facebook_id == $facebook.facebook_id)
      Member.add_credit_to_facebook_id(@comment.facebook_id,-POINT_VOTE_COMMENT)
      @comment.status = Comment::STATUS_DELETED
      @comment.save
    end
    
    render :json => {:ok=>true,:credits=>$facebook.credits,:previous_credits=>$facebook[:previous_credits]}
  end
  
def share_comment
    @comment = Comment.first(:conditions=>{:id => params[:comment_id]})
    
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
      
      return_url = "http://#{DOMAIN_NAME}/comment/share_after_allow/#{@comment.id}/#{ticket.unique_key}"
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
    @comment = Comment.first(:conditions=>{:id => params[:comment_id]})
    ticket = ShareTicket.first(:conditions=>{:unique_key=>params[:share_unique_key]})
    
    if ticket and ticket.status == ShareTicket::STATUS_PENDING

      result = $facebook.publish_comment(@comment,ticket.ref)
 
      if result[:ok] == true
        ticket.status = ShareTicket::STATUS_COMPLETED
      else
        ticket.status = ShareTicket::STATUS_ERROR
        ticket.error_message = result[:error_message] if result[:error_message]
      end
      
      ticket.finished_date = Time.now
      
      ticket.save
    end
    
    @figure = Figure.first(:conditions=>{:id=>@comment.figure_id})
     
    redirect_to @figure.get_url
   
 end
end
