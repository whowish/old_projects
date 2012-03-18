class ReplyController < ApplicationController
  
  def add
    
    strip_all_params
    
    kratoo = Kratoo.find(params[:kratoo_id])
    entity = Reply.new(:kratoo_id=>kratoo.id)
    
    errors = ReplyValidator.validate({:content=>params[:content]})
    
    begin
      entity.post_owner = PostOwner.create_object(kratoo,
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
      render :json=>{:ok=>false,:error_messages=>{:summary=>"The reply cannot be saved. Please try again later."}}
      return
    end
    
    
    kratoo.inc(:reply_count, 1)
    kratoo.inc(:all_reply_count, 1)
    
    
    
    entity.reply_running_number = kratoo.update_running_number()
    entity.save
    
    kratoo.update_score_reply
    
    VersioningObject.add(entity)
    
    Resque.enqueue(ReplyNotification, entity.id)
    KratooDistributor.enqueue(kratoo.id)
    MemberAction.post(entity,$member.id)
    
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"/reply/unit",:locals=>{:entity=>entity}),:identity_panel=>(render_to_string :partial=>"/reply/identity_panel",:locals=>{:kratoo=>kratoo})}
  end
  
  def agree
  
    if $member.is_guest
      render :json=>{:ok=>false,:error_message=>"You need to login in order to agree/disagree."}
      return 
    end
   
    entity = Reply.find(params[:reply_id])
    
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
        html = render_to_string(:partial=>"reply/agree",:locals=>{:entity=>entity,:agrees=>agrees,:disagrees=>disagrees})
      when Agreeable::AGREEABLE_TYPE_DISAGREE
        disagrees += 1
        html = render_to_string(:partial=>"reply/disagree",:locals=>{:entity=>entity,:agrees=>agrees,:disagrees=>disagrees})
      else
        html = render_to_string(:partial=>"reply/unagree",:locals=>{:entity=>entity,:agrees=>agrees,:disagrees=>disagrees})
    end
    
    entity.member_agree($member,params[:agree_type])
    
    render :json=>{:ok=>true,:html=>html}
  
  end

  def agree_user
    reply = Reply.find(params[:reply_id])
    ids = reply.get_agree_user(params[:agree_type])
    
    users = Member.where(:_id.in=>ids).entries
    html = ""
   
    html = render_to_string(:partial=>"reply/agree_list_user",:locals=>{:users=>users})
     
    
    render :json=>{:ok=>true,:html=>html}
  
  end
  
  def index
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"/reply/panel",:locals=>{:entity=>Kratoo.find(params[:kratoo_id])})}
  end
  
  def delete
    if $member.is_guest
      render :json=>{:ok=>false,:error_messages=>"please login first!"}
      return
    end

    entity = Reply.find(params[:reply_id])
    DeletedObject.delete(entity,$member.id)
    entity.kratoo.inc(:reply_count, -1)
    entity.kratoo.inc(:all_reply_count, -1)
    Reply.where(:id=>entity.id).destroy_all
    render :json=>{:ok=>true}
  end
  
  def edit
    
    errors = ReplyEditValidator.validate({:content=>params[:content]})

    if errors.length > 0
      render :json=>{:ok=>false,:error_messages=>errors}
      return
    end
    
    entity = Reply.find(params[:reply_id])
    entity.content.set_html(params[:content])
    entity.updated_date = Time.now
    
    if !entity.save
      render :json=>{:ok=>false,:error_messages=>{:summary=>"The reply cannot be saved. Please try again later."}}
      return
    end
    
    VersioningObject.add(entity)
    render :json=>{:ok=>true,:kratoo_id=>entity.kratoo.id}
  end
  
  
end
