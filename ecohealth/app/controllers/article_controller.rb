class ArticleController < ApplicationController
  
  def add
    entity = Article.new
    entity.title = params[:title]
    entity.created_date = Time.now.utc.to_i
    entity.main_image_path = ""
    entity.member_id = $member.id
    entity.abstract = params[:abstract]
    entity.content = params[:content]
    entity.course = Course[params[:course_id]]
    entity.save
    
    render :json=>{:ok=>true,:url=>"/article/view?id=#{entity.id}"}
  end
  
  def edit
    entity = Article[params[:id]]
    entity.title = params[:title]
    entity.main_image_path = ""
    entity.member_id = $member.id
    entity.abstract = params[:abstract]
    entity.content = params[:content]
    entity.save
    
    render :json=>{:ok=>true,:url=>"/article/view?id=#{entity.id}"}
  end
  def delete
    entity = Article[params[:id]]
    DeletedObject.delete(entity)
    entity.delete
    render :json=>{:ok=>true}
  end
end
