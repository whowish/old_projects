class CourseController < ApplicationController
  def add
    if $member.is_guest
      render :json=>{:ok=>false,:error_message=>"please login first!"}
      return
    end
    
    entity = Course.new
    entity.title = params[:title]
    entity.description = params[:description]
    entity.created_date = Time.now.utc.to_i
    entity.main_image_path = params[:image]
    entity.member_id = $member.id
    entity.save
    render :json=>{:ok=>true,:url=>"/course/view?id=#{entity.id}"}
  
  end
  def edit
     if $member.is_guest
      render :json=>{:ok=>false,:error_message=>"please login first!"}
      return
    end
    
    entity = Course[params[:id]]
    entity.title = params[:title]
    entity.description = params[:description]
    entity.main_image_path = params[:image]
    entity.save
    render :json=>{:ok=>true,:url=>"/course/view?id=#{entity.id}"}
  end
  def delete
    if $member.is_guest
      render :json=>{:ok=>false,:error_message=>"please login first!"}
      return
    end
    
    entity = Course[params[:id]]
    DeletedObject.delete(entity)
    entity.delete
    render :json=>{:ok=>true}
  end
end
