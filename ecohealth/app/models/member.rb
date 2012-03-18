class Member < ActiveRecord::Base
  include MemberHelper
  STATUS_PENDING = "PENDING"
  STATUS_APPROVED = "APPROVED"
  STATUS_DELETED = "DELETED"
  
  TYPE_PROFESSOR = "PROFESSOR"
  TYPE_GENERAL = "GENERAL"
  TYPE_RESEARCHER = "RESEARCHER"
  
  MEMBER_TYPES = [TYPE_PROFESSOR,TYPE_GENERAL,TYPE_RESEARCHER]
  
  validates_format_of :email, :with => /[a-zA-Z0-9]+@[a-zA-Z0-9]+/, :message => MemberErrorMessage::EMAIL_INVALID_FORMAT
  validates_presence_of :email, :message => MemberErrorMessage::EMAIL_EMPTY
  validates_length_of :email, :minimum =>4, :message => MemberErrorMessage::EMAIL_MINIMUM_LENGTH
  validates_length_of :email, :maximum =>255, :message => MemberErrorMessage::EMAIL_MAXIMUM_LENGTH
  #validates_uniqueness_of :email, :message => MemberErrorMessage::EMAIL_NOT_UNIQUE
  
  def is_guest
    return (id == nil)
  end
  
  def self.get_guest
    return Member.new(:name=>"Guest",:email=>"-")
  end
  
  def get_thumbnail_profile_picture_path()
    return get_profile_picture_path(true)
  end
  
  def get_profile_picture_path(thumb=false)
    if self.profile_picture_path != nil and self.profile_picture_path != ""
      if thumb
        return get_thumbnail_url(self.profile_picture_path, 50, 50)
      else
        return get_thumbnail_url(self.profile_picture_path, 200, 0)
      end
    else
      if thumb
        return "/images/thumb_default_pic.jpg"
      else
        return "/images/default_pic.jpg"
      end
    end
  end
  
  def keep_stat(prefix_key,incr_by)
      current_time = Time.now.utc
      current_time_sec = current_time.to_i
      
      hour_sec = current_time_sec - current_time_sec%3600
      day_sec = hour_sec - (3600*current_time.hour)
      week_sec = day_sec - (3600*24*current_time.wday)
      month_sec = day_sec - (3600*24*(current_time.mday-1))
      year_sec = day_sec - (3600*24*(current_time.yday-1))
      
      Ohm.redis.zincrby("#{prefix_key}:hourly:#{hour_sec}",incr_by)
      Ohm.redis.zincrby("#{prefix_key}:daily:#{day_sec}",incr_by)
      Ohm.redis.zincrby("#{prefix_key}:weekly:#{week_sec}",incr_by)
      Ohm.redis.zincrby("#{prefix_key}:monthly:#{month_sec}",incr_by)
      Ohm.redis.zincrby("#{prefix_key}:yearly:#{year_sec}",incr_by)
  end
  
  def is_agree_with_article(article_id)
    return Ohm.redis.get("MemberAgreeArticle:#{self.id}:#{article_id}") == "agree"
  end
  
  def agree_with_article(article_id)
    previous = Ohm.redis.getset("MemberAgreeArticle:#{self.id}:#{article_id}","")
    
    if previous == nil or previous == ""
      keep_stat("Article:#{article_id}",1)
    end
  end
  
  def unagree_with_article(article_id)
    previous = Ohm.redis.getset("MemberAgreeArticle:#{self.id}:#{article_id}","")
    
    if previous == "agree"
      ckeep_stat("Article:#{article_id}",-1)
    end
  end
  
  def is_agree_with_comment(comment_id)
    return Ohm.redis.get("MemberAgreeComment:#{self.id}:#{comment_id}") == "agree"
  end
  
  def agree_with_comment(comment_id)
    previous = Ohm.redis.getset("MemberAgreeComment:#{self.id}:#{comment_id}","agree")
    
    if previous == nil or previous == ""
      keep_stat("Comment:#{comment_id}",1)
    end
    
  end
  
  def unagree_with_comment(comment_id)
    previous = Ohm.redis.getset("MemberAgreeComment:#{self.id}:#{comment_id}","")
    
    if previous == "agree"
      keep_stat("Comment:#{comment_id}",-1)
    end
  end
end