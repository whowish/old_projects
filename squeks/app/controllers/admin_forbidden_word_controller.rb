class AdminForbiddenWordController < ApplicationController
  layout 'valhalla'
  before_filter :check_admin
  
  def add
    forbidden = ForbiddenWord.new()
    forbidden.word = params[:word]
    forbidden.save
    render :json=>{:ok=>true,:word_view=>render_to_string(:partial=>"/admin_forbidden_word/word_unit",:locals=>{:word=>forbidden})}
  end
  
  def edit
    forbidden = ForbiddenWord.first(:conditions=>{:id=>params[:id]})
    forbidden.word = params[:word]
    forbidden.save
    render :json=>{:ok=>true}
  end
  
  def delete
    forbidden = ForbiddenWord.first(:conditions=>{:id=>params[:id]})
    forbidden.destroy
    render :json=>{:ok=>true}
  end
end
