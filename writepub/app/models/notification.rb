class Notification
  include Mongoid::Document 

  field :notified_member_id, :type=>String
  field :is_read, :type=>Boolean
  field :created_date, :type=>DateTime
  
  index [
          [:notified_member_id, Mongo::DESCENDING],
          [:is_read, Mongo::ASCENDING],
          [:created_date, Mongo::DESCENDING]
        ]
        
  index [
          [:notified_member_id, Mongo::DESCENDING],
          [:created_date, Mongo::DESCENDING]
        ]
  
  
  before_create do |record|
    record.created_date = Time.now
  end
  
end