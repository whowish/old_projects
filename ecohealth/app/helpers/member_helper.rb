module MemberHelper
  include ThumbnailismHelper

  def process_login(email,password,force=false)
    require 'digest/md5'
    md5_password = Digest::MD5.hexdigest(params[:password])
    
    member = Member.first(:conditions=>{:email=>email})
    
    return false,"Either email or password is invalid." if !member
    
    if member.status == Member::STATUS_PENDING
      MemberMailer.send_later(:deliver_notify_member_confirmation,member)
      return false,"The registration has not been approved. <br/>Please confirm your registration by email."
    end
    if member.status == Member::STATUS_DELETED
      return false,"Email is invalid."
    end
    
    return false,"Either email or password is invalid." if member.password != md5_password and !force

    session[:member_id] = member.id
    
    return true
  end
  def update_picture(new_picture_path)
    if new_picture_path == ""
      return
    end
      old_image_path = self.profile_picture_path
      if old_image_path and old_image_path != nil
        delete_image(old_image_path)
      end
      inner_add_image(new_picture_path)
  end
  
  def inner_add_image(temp_image)
    ext = File.extname(temp_image).sub(/^\./, "").downcase
    new_img_name = "member_pic"+"_" + self.id.to_s + "." + ext
    begin
      image_copy(temp_image, new_img_name)
    rescue
    end
    begin
      MEMBER_THUMBNAIL_SIZES.each { |size|
        tokens = size.split('x')
        make_thumbnail(new_img_name, tokens[0].to_i, tokens[1].to_i)
      }
    rescue Exception => e
      print "error=> "+e.to_s
    end
    self.profile_picture_path = new_img_name
    self.save
    delete_image(temp_image)
  end
end
