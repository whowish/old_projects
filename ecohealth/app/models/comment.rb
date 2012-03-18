class Comment < Ohm::Model
  attribute :content
  attribute :created_date
  
  
  counter :agree
  reference :article, Article
  
  attribute :member_id
  index :member_id
end