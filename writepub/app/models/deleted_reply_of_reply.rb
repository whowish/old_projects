class DeletedReplyOfReply < DeletedObject
  include Mongoid::Document
    field :kratoo_id, :type => String
    field :reply_id, :type => String
    field :reply_of_reply_id, :type=>String
    embeds_one :object_data,:class_name=>"ReplyOfReply"
    
    index [
            [:kratoo_id, Mongo::DESCENDING ],
            [:reply_id, Mongo::DESCENDING ],
            [:reply_of_reply_id, Mongo::DESCENDING ],
          ]
end