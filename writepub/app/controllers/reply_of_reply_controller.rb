class ReplyOfReplyController < ApplicationController
  
  def add
    
    strip_all_params
    
    reply = Reply.find(params[:reply_id])
    entity = ReplyOfReply.new(:reply_id=>reply.id)

    errors = ReplyOfReplyValidator.validate({:content=>params[:content]})

    begin
      entity.post_owner = PostOwner.create_object(reply.kratoo,
                                                  $member,
                                                  params[:username],
                                                  params[:is_anonymous],
                                                  request.remote_ip)
    rescue PostOwnerException=>e
      errors.merge!(e.message) 
    end
    
    if errors.length > 0
      render :json=>{:ok=>false,:error_messages=>errors}
      return
    end
    
    entity.content = RichContent.new
    entity.content.set_html(params[:content])
    entity.created_date = Time.now
    entity.updated_date = Time.now
    
    if !entity.save
      render :json=>{:ok=>false,:error_messages=>{:summary=>"The reply of reply cannot be saved. Please try again later."}}
      return
    end
    
    VersioningObject.add(entity)
    Resque.enqueue(ReplyOfReplyNotification, entity.id)
    
    reply.kratoo.update_score_reply
    KratooDistributor.enqueue(reply.kratoo.id)
    MemberAction.post(entity,$member.id)
    
    reply.kratoo.inc(:all_reply_count, 1)
    
    render :json=>{:ok=>true,:reply_id=>entity.id,:html=>(render_to_string :partial=>"/reply_of_reply/unit",:locals=>{:entity=>entity})}
  end
  
  def agree
    
    if $member.is_guest
      render :json=>{:ok=>false,:error_message=>"You need to login in order to agree/disagree."}
      return 
    end
   
    entity = ReplyOfReply.find(params[:reply_of_reply_id])
    
    agrees = entity.agrees
    disagrees = entity.disagrees
    
    previous_value = entity.is_agree_or_disagree($member.id)

    case previous_value 
      when Agreeable::AGREEABLE_TYPE_AGREE
        agrees -= 1
      when Agreeable::AGREEABLE_TYPE_DISAGREE
        disagrees -= 1
    end
    
    html = ""
    case params[:agree_type] 
      when Agreeable::AGREEABLE_TYPE_AGREE
        agrees += 1
        html = render_to_string(:partial=>"reply_of_reply/agree",:locals=>{:entity=>entity,:agrees=>agrees,:disagrees=>disagrees})
      when Agreeable::AGREEABLE_TYPE_DISAGREE
        disagrees += 1
        html = render_to_string(:partial=>"reply_of_reply/disagree",:locals=>{:entity=>entity,:agrees=>agrees,:disagrees=>disagrees})
      else
        html = render_to_string(:partial=>"reply_of_reply/unagree",:locals=>{:entity=>entity,:agrees=>agrees,:disagrees=>disagrees})
    end
    
    entity.member_agree($member,params[:agree_type])
    
    render :json=>{:ok=>true,:html=>html}  
  end
  
  def agree_user
    ror = ReplyOfReply.find(params[:reply_of_reply_id])
    ids = ror.get_agree_user(params[:agree_type])
    
    users = Member.where(:_id.in=>ids).entries
    html = ""
   
    html = render_to_string(:partial=>"reply_of_reply/agree_list_user",:locals=>{:users=>users})
     
    
    render :json=>{:ok=>true,:html=>html}
  
  end
  
  def delete
    if $member.is_guest
      render :json=>{:ok=>false,:error_message=>"please login first!"}
      return
    end

    entity = ReplyOfReply.find(params[:reply_of_reply_id])
    
    DeletedObject.delete(entity,$member.id)
    
    entity.reply.kratoo.inc(:all_reply_count, -1)
    
    ReplyOfReply.where(:id=>entity.id).destroy_all
    
    render :json=>{:ok=>true}
  end
  
  def edit
    
    entity = ReplyOfReply.find(params[:reply_of_reply_id])

    errors = ReplyOfReplyEditValidator.validate({:content=>params[:content]})

    if errors.length > 0
      render :json=>{:ok=>false,:error_messages=>errors}
      return
    end
    
    entity.content.set_html(params[:content])
    entity.updated_date = Time.now
    
    if !entity.save
      render :json=>{:ok=>false,:error_messages=>{:summary=>"The reply cannot be saved. Please try again later."}}
      return
    end
    
    VersioningObject.add(entity)
    render :json=>{:ok=>true,:kratoo_id=>entity.reply.kratoo.id}
  end
end
