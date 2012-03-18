require 'bcrypt'
class Member
  include Mongoid::Document
  include UniqueIdentity
  include MemberCookies
  
  GENDER_MALE = "MALE"
  GENDER_FEMALE = "FEMALE"
  GENDER_GAY = "GAY"
  GENDER_BISEXUAL = "BISEXUAL"
  GENDER_LESBIAN = "LESBIAN"
  GENDER_ASEXUAL = "ASEXUAL"
  GENDER_CHOICES = [GENDER_MALE,GENDER_FEMALE,GENDER_GAY,GENDER_BISEXUAL,GENDER_LESBIAN,GENDER_ASEXUAL]
  
  field :username, :type=>String
  field :username_downcase, :type=>String
  field :password, :type=>String
  
  field :cookies_salt, :type=>String
  
  field :profile_picture_path, :type=>String
  field :created_date, :type => DateTime
  field :facebook_id, :type=>String
  field :phone_number, :type=>String
  field :email, :type=>String
  field :is_admin, :type=>Boolean
  field :is_verified, :type=>Boolean
  field :fame, :type=>Integer
  field :about, :type=>String
  field :quote, :type=>String
  field :gender, :type=>String
  
  index :username_downcase, :unique=>true
  index :email, :unique=>true
  index :facebook_id, :unique=>true
  
  before_create :ensure_sparse,:ensure_username_downcase, :generate_salt
  
  def generate_salt
    self.cookies_salt = SecureRandom.base64(64)
  end
  
  def ensure_username_downcase
    self.username_downcase = self.username.downcase
  end
  
  def ensure_sparse
    self.email = " #{self.id.to_s}" if self.email == nil
    self.facebook_id = " #{self.id.to_s}" if self.facebook_id == nil
  end
  
  def email
    return nil if self[:email] == " #{self.id}"
    return self[:email]
  end
  
  def facebook_id
    return nil if self[:facebook_id] == " #{self.id}"
    return self[:facebook_id]
  end
  
  def is_guest
    return !self.persisted?
  end
  
  def is_member
    return !is_guest
  end
  
  def self.get_guest
    return Member.new(:_id=>nil,:username=>"Guest",:email=>"-")
  end
  
  def get_thumbnail_profile_picture_path()
    return get_profile_picture_path(true)
  end
  
  def get_profile_picture_path(thumb=false)
    if self.profile_picture_path != nil and self.profile_picture_path != ""
      if thumb
        return get_thumbnail_path(self.profile_picture_path, 50, 50)
      else
        return self.profile_picture_path
      end
    else
      if thumb
        return "/images/default_profile_picture_thumbnail.jpg"
      else
        return "/images/default_profile_picture.jpg"
      end
    end
  end
  
  def get_thumbnail_path(path, width, height)
    
    dir = File.dirname(path)
    ext = File.extname(path).downcase
    name = File.basename(path, ext)   
    
    return "#{dir}/#{name}_#{width.to_i}x#{height.to_i}#{ext}"
    
  end
  
  
  def get_badge
    profile_url = "/profile/#{self.id}"
    return  '<a href="'+profile_url+'" title="Go to Profile" class="username">'+self.username+'</a>'
  end
  
  
  def is_password_valid(password)
    password_hash = BCrypt::Password.new(self.password)
    return password_hash == password
  rescue
   return false
 end
 
  def self.encrypt_password(password)
    
    return BCrypt::Password.create(password).to_s
  end
  
end
