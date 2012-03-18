class FacebookMember < Member

  field :facebook_id, :type => String

  index [[:facebook_id, Mongo::ASCENDING]]
  
  before_create :create_global_id
  
  def url
    "http://www.facebook.com/profile.php?id=#{self.facebook_id}"
  end
  
  private
  def create_global_id
    self.global_id = "facebook_#{self.facebook_id}"
  end
 
end