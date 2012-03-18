class Course < Ohm::Model
  attribute :title
  attribute :description
  attribute :created_date
  attribute :main_image_path
  attribute :member_id
  
  collection :articles, Article

  index :member_id
  
  def to_hash
    super.merge({:title=>title,:created_date=>created_date,:main_image_path=>main_image_path,:member_id=>member_id})
  end
end