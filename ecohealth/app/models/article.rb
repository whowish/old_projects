class Article < Ohm::Model
  attribute :title
  attribute :created_date
  attribute :main_image_path
  attribute :member_id
  attribute :abstract
  attribute :content
  set :images,nil
  
  reference :course, Course
  list :comments, Comment
  
  counter :agree
  counter :read
  
  index :member_id
  
  def to_hash
    super.merge({:title=>title,:created_date=>created_date,:main_image_path=>main_image_path,
                  :member_id=>member_id,:content=>content,:images=>images,
                  :course=>course,:comments=>comments,:agree=>agree,:read=>read})
  end
  
end