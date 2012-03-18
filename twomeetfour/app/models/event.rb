class Event
  include Mongoid::Document
  include UniqueIdentity
  
  field :title, :type=>String
  field :description, :type=>String
  field :created_date, :type => Time, :default => lambda{ Time.now.utc }
  
  field :member_id, :type=>String

  index [[:member_id, Mongo::DESCENDING]], :unique=>true


end