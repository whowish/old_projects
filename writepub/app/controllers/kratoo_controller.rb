class KratooController < ApplicationController
  
  def add
    
    strip_all_params
    
    errors = KratooValidator.validate({:title=>params[:title],
                                       :content=>params[:content],
                                       :kratoo_type=>params[:kratoo_type]})

    entity = Kratoo.new

    begin
      entity.post_owner = PostOwner.create_object(entity,
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
    
    entity.title = params[:title]
    entity.content = RichContent.new
    entity.content.set_html(params[:content])
    entity.kratoo_type = params[:kratoo_type]
    
    if !entity.save
      render :json=>{:ok=>false,:error_message=>{:summary=>"The kratoo cannot be saved. Please try again later."}}
      return
    end
    
    entity.update_score_post
    KratooDistributor.enqueue(entity.id)
    MemberAction.post(entity,$member.id)
    
    entity.tag_ids = []
    params[:tags].split(",").each { |tag_name|
      tag = Tag.find_or_create_by(:name=>tag_name.strip)
      entity.tag_ids.push(tag.id)
    }
    
    MongoidHelper.commit_database
    entity.organize_tags
    
    versioning_kratoo = entity
    VersioningObject.add(versioning_kratoo)

    render :json=>{:ok=>true,:kratoo_id=>entity.id}
    
  end
  
  def edit_kratoo

    errors = KratooEditValidator.validate({:title=>params[:title],
                                       :content=>params[:content]})

    if errors.length > 0
      render :json=>{:ok=>false,:error_messages=>errors}
      return
    end
    
    entity = Kratoo.find(params[:kratoo_id])
    entity.title = params[:title]
    entity.content.set_html(params[:content])
    entity.updated_date = Time.now
    
    if !entity.save
      render :json=>{:ok=>false,:error_messages=>{:summary=>"The kratoo cannot be saved. Please try again later."}}
      return
    end
    
    VersioningObject.add(entity)
    render :json=>{:ok=>true,:kratoo_id=>entity.id}
  end
  
  def agree
    
    if $member.is_guest
      render :json=>{:ok=>false,:error_message=>"You need to login in order to agree/disagree."}
      return 
    end
   
    kratoo = Kratoo.find(params[:kratoo_id])
    
    agrees = kratoo.agrees
    disagrees = kratoo.disagrees
    
    previous_value = kratoo.is_agree_or_disagree($member.id)

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
        html = render_to_string(:partial=>"kratoo/agree",:locals=>{:entity=>kratoo,:agrees=>agrees,:disagrees=>disagrees})
      when Agreeable::AGREEABLE_TYPE_DISAGREE
        disagrees += 1
        html = render_to_string(:partial=>"kratoo/disagree",:locals=>{:entity=>kratoo,:agrees=>agrees,:disagrees=>disagrees})
      else
        html = render_to_string(:partial=>"kratoo/unagree",:locals=>{:entity=>kratoo,:agrees=>agrees,:disagrees=>disagrees})
    end
    
    kratoo.member_agree($member,params[:agree_type])
    
    render :json=>{:ok=>true,:html=>html}
  
   end

   def agree_user
    kratoo = Kratoo.find(params[:kratoo_id])
    ids = kratoo.get_agree_user(params[:agree_type])
    
    users = Member.where(:_id.in=>ids).entries
    html = ""
   
    html = render_to_string(:partial=>"kratoo/agree_list_user",:locals=>{:users=>users})
     
    
    render :json=>{:ok=>true,:html=>html}
  
  end

  def delete
    if $member.is_guest
      render :json=>{:ok=>false,:error_message=>"please login first!"}
      return
    end

    entity = Kratoo.first(:conditions=>{:id=>params[:kratoo_id]})
    DeletedObject.delete(entity,$member.id)
    Kratoo.where(:id=>entity.id).destroy_all
    
    render :json=>{:ok=>true,:url=>"/kratoo/delete_successfully"}
  end
  
  def view
    @kratoo = Kratoo.first(:conditions=>{:id=>params[:id]})
    
    if !@kratoo
      render :invalid
      return
    end
    
    @kratoo.update_score_read(request.remote_ip)
  end
  
  def list
    params[:sort] ||=  "recent"
    @sort = (params[:sort] == "top") ? (:score) : (:created_date)
    params[:sort] = (@sort == :score) ? "top" : "recent"

    fields_to_queried = [:title,:created_date,:kratoo_type,:reply_count,:post_owner,:agrees]
    @kratoos = Kratoo.only(*fields_to_queried).desc(*@sort)
    @tag_does_not_exist = false
  
    params[:page] ||= 1
    params[:page] = params[:page].to_i
    if @sort == :created_date
      @kratoos = @kratoos.where(:created_date.lt => (params[:page]-1).week.ago)
      @kratoos = @kratoos.where(:created_date.gte => params[:page].week.ago)
    end
        
    params[:tag] ||= ""
    params[:tag] = params[:tag].strip
    if params[:tag] != ""
      @tag = Tag.first(:conditions=>{:name=>params[:tag]})
  
      if @tag
        @kratoos = @kratoos.where(:all_tag_ids=>@tag.id)
      else
        @tag_does_not_exist = true
      end
    end
  
    @kratoos = @kratoos.entries
  end
  
end
