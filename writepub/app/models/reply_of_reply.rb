class ReplyOfReply
  include Mongoid::Document 
  include ReplyOfReplyAgreeable
  
  embeds_one :content, :as => :rich_content, :class_name => "RichContent"
  embeds_one :post_owner
  field :created_date, :type=>DateTime
  field :updated_date, :type=>DateTime
  field :agrees, :type => Integer, :default=>0
  field :disagrees, :type => Integer, :default=>0
  
  belongs_to :reply

  index [
          [ :reply_id, Mongo::ASCENDING  ],
          [ :created_date, Mongo::ASCENDING  ]
        ]
        
        
  before_create do |record|
    record.created_date = Time.now
    record.updated_date = Time.now
  end
  
  after_create do |record|

    member = Member.new(:id=>record.post_owner.member_id) # mock member without querying
    
    if record.reply.kratoo.get_post_owner_type(member) == ""
     
      if record.post_owner.instance_of?(OwnerPublic)
        
        record.reply.kratoo.set_post_owner_type(member,"OwnerPublic")
        
      elsif record.post_owner.instance_of?(OwnerAnonymous)
        
        record.reply.kratoo.set_anonymous_name(member, record.post_owner.username)
        record.reply.kratoo.set_post_owner_type(member, "OwnerAnonymous")
        
      end
      
    end
    
  end
    
  
  
  before_save do |record|
    record.updated_date = Time.now
  end
 

  before_destroy do |record|
    if $member
      ReplyOfReplyRemover.enqueue(record.id,$member.id)
    else
      ReplyOfReplyRemover.enqueue(record.id,'')
    end
  end
end