class TemporaryFile
  include Mongoid::Document
  include ThumbnailismHelper::UniqueIdentity
  
  field :name,:type=>String
  field :created_date,:type=>DateTime

end