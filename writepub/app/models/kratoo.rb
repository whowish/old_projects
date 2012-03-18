#
# When a tag is searched, its outgoing tags is also pulled recursively.
# A tag graph might forms circles, and it is ok to be that way.
#
# Kratoo can contains AliasTag in its tags (for displaying purpose),
# but it cannot contains AliasTag in its all_tags (for searching purpose);
#
# This way an alias tag can be shown to suit individual's culture;
# Its semantics is still the same.
#
class Kratoo
  include Mongoid::Document 
  include KratooAgreeable
  include KratooAnonymityHandler
  include KratooReading
  include KratooTagHandler
  include KratooSunspot
  include UniqueIdentity
  include ReplyCount
  
  
  TYPE_GENERAL = "GENERAL"
  TYPE_QUESTION = "QUESTION"
  TYPE_LIVE_REPORT = "LIVE_REPORT"
  TYPE_REVIEW = "REVIEW"
  TYPE_VOTE = "VOTE"
  KRATOO_TYPES = [TYPE_GENERAL,TYPE_QUESTION,TYPE_LIVE_REPORT,TYPE_REVIEW,TYPE_VOTE]
  
  
  field :title, :type=>String
  field :kratoo_type, :type=>String
  embeds_one :content, :as => :rich_content, :class_name => "RichContent"
  embeds_one :post_owner 
  field :created_date, :type=>DateTime
  field :updated_date, :type=>DateTime
  field :reply_running_number, :type => Integer, :default=>0
  field :reply_count, :type => Integer, :default=>0
  field :all_reply_count, :type => Integer, :default=>0
  field :views, :type=>Integer, :default=>0
  field :score, :type=>Float, :default=>0
 
  has_many :replies, :class_name=>"Reply", :order=>"reply_running_number.asc"
  
  field :tag_ids, :type=>Array, :default=>[]
  field :all_tag_ids, :type=>Array, :default=>[]
  
  field :context_words, :type=>Array, :default=>[]


  index :all_tag_ids
  index [[ :created_date, Mongo::DESCENDING  ]]
  index [[ :score, Mongo::DESCENDING  ]]
  
  before_create do |record|
    record.created_date = Time.now
    record.updated_date = Time.now
  end
  
  after_create do |record|
    
    member = Member.new(:id=>record.post_owner.member_id) # mock member without querying

    if record.get_post_owner_type(member) == ""
     
      if record.post_owner.instance_of?(OwnerPublic)
        
        record.set_post_owner_type(member, "OwnerPublic")
        
      elsif record.post_owner.instance_of?(OwnerAnonymous)
        
        record.set_anonymous_name(member, record.post_owner.username)
        record.set_post_owner_type(member, "OwnerAnonymous")
        
      end
    
    end
    
  end
  
  before_destroy do |record|
    if $member
      KratooRemover.enqueue(record.id,$member.id)
    else
      KratooRemover.enqueue(record.id,'')
    end
  end

end