class ArticleCommentController < ApplicationController
   def add
    entity = Comment.new
    entity.created_date = Time.now.utc.to_i
    entity.member_id = $member.id
    entity.content = params[:content]
    entity.article = Article[params[:article_id]]
    entity.save
    entity.article.comments.unshift(entity)
    entity.save
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"article_comment/comment_view",:locals=>{:entity=>entity})}
  end
  def delete
    entity = Comment[params[:id]]
    entity.article.comments.delete(entity.id)
    DeletedObject.delete(entity)
    entity.delete
    render :json=>{:ok=>true}
  end
  def index
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"comment_panel",:locals=>{:entity=>Article[params[:article_id]]})}
  end
end
