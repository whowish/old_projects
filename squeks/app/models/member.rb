class Member < ActiveRecord::Base

  STATUS_ACTIVE = "ACTIVE"
  STATUS_BANNED = "BANNED"
  
  attr_accessor :country_code

  def after_initialize
    self.country_code = "US"
  end

  def set_facebook_cache(facebook_cache)
    @facebook_cache = facebook_cache

    self.name = @facebook_cache.name
    self.gender = @facebook_cache.gender

    self.save if !@facebook_cache.is_guest
  end

  def is_guest
    return (facebook_id == nil or facebook_id == 0)
  end

  def self.get_guest
    m = Member.new(:name=>"Guest",:is_anonymous=>false)
    m.set_facebook_cache(FacebookCache.get_guest)
    return m
  end
  
  def self.add_credit_to_facebook_id(facebook_id,credit)
    credit = credit.to_i
    return if credit == 0
    
    ActiveRecord::Base.connection.execute("UPDATE `members` SET `credits`=`credits`+#{credit} WHERE `facebook_id`='#{facebook_id}'")
    
  end
  
  def profile_picture_url(type="square")
    if is_guest
      if type == "square"
        return "/whowish_foundation_asset/facebook_blank_profile.jpg"
      else
        return "/whowish_foundation_asset/facebook_blank_profile_big.jpg"
      end
    else
      return "http://graph.facebook.com/"+facebook_id.to_s+"/picture?type="+type
    end
    
  end
  
  def add_credit(credit)
    
    return if self.is_guest
    
    credit = credit.to_i
    
    return if credit == 0
    
    Member.add_credit_to_facebook_id(self.facebook_id,credit)
    self[:previous_credits] = self.credits
    self.credits += credit
  end
  
  #facebook_cache proxy
  def method_missing(symbol, *args)
    begin
      super.method_missing(symbol, *args)
    rescue
      begin
        @facebook_cache.send(symbol,*args)
      rescue Exception=>e
        raise e
      end
    end
  end

  
  def anonymous_profile_picture_url
    
    return "" if is_guest
    
    if ENV['S3_ENABLED']
      "http://s3.amazonaws.com/#{AWS_S3_BUCKET_NAME}#{anonymous_profile_pic}"
    else
      anonymous_profile_pic
    end
  end

  before_create :generate_anonymous_name

  def generate_anonymous_name
      if self.anonymous_name != nil
        return
      end

      srand(Time.now.to_i + 1)
      chars = 'abcdefghjkmnpqrstuvwxyz123456789'

      token = ""
      success = false
      while !success

        token = ''
        10.times { token << chars[rand(chars.size)] }

        if !self.class.first(:conditions=>{:anonymous_name=>token})
          break;
        end
      end

      self.anonymous_name = token
    end
end