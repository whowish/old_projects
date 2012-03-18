class Room
  include Mongoid::Document
  
  field :description, :type=>String
  field :ordered_number, :type=>Integer
  field :tag,:type=>String
  
  index [[ :ordered_number, Mongo::ASCENDING  ]]
end