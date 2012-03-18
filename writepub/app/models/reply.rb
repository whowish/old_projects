class Reply
  include Mongoid::Document 
  include ReplyAgreeable


  AGREEABLE_TYPE_AGREE = "AGREE"
  AGREEABLE_TYPE_DISAGREE = "DISAGREE"
 
 
  belongs_to :kratoo
  
  embeds_one :content, :as => :rich_content, :class_name => "RichContent"
  embeds_one :post_owner
  field :created_date, :type=>DateTime
  field :updated_date, :type=>DateTime
  field :reply_running_number, :type => Integer, :default=>0
 
  
  has_many :replies, :class_name=>"ReplyOfReply", :order=>"created_date.asc"

  index [[ :kratoo_id, Mongo::ASCENDING  ],[ :created_date, Mongo::ASCENDING  ]]
  
  
  before_create do |record|
    record.created_date = Time.now
    record.updated_date = Time.now
  end
  
  after_create do |record|
    
    member = Member.new(:id=>record.post_owner.member_id) # mock member without querying
    
    if record.kratoo.get_post_owner_type(member) == ""

      if record.post_owner.instance_of?(OwnerPublic)
        
        
        record.kratoo.set_post_owner_type(member,"OwnerPublic")
        
      elsif record.post_owner.instance_of?(OwnerAnonymous)
        
        record.kratoo.set_anonymous_name(member, record.post_owner.username)
        record.kratoo.set_post_owner_type(member, "OwnerAnonymous")
        
      end
    
    end
    
  end
  
  
  before_save do |record|
    record.updated_date = Time.now
  end
 
 
  before_destroy do |record|
    if $member
      ReplyRemover.enqueue(record.id,$member.id)
    else
      ReplyRemover.enqueue(record.id,'')
    end
  end

end