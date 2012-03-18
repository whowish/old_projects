class Figure < ActiveRecord::Base
  include ImageHelper
  include FigureHelper
  
  STATUS_ACTIVE = "ACTIVE"
  STATUS_DELETED = "DELETED"
  STATUS_PENDING = "PENDING"
  STATUS_BEING_MERGED = "BEING_MERGED"
  
  BID_STATUS_SETTLED = "SETTLED"
  BID_STATUS_BIDDING = "BIDDING"
  

  
  def active?(strict=false)
    if strict
      return STATUS_ACTIVE == self.status
    else
      return [STATUS_ACTIVE,STATUS_PENDING].include?(self.status)
    end
  end
  
  def get_url(string_url=true)
    begin
      if string_url == true
        return "/home/#{self.title.gsub(" ","_")}"
      else
        return "/home/#{self.id}"
      end
    rescue
      return "/home/#{self.id}"
    end
  end

  def set_default_image
    default_figure_image = FigureImage.first(:conditions=>{:figure_id=>self.id},:order=>"(likes - dislikes) desc")
    self.default_pic = default_figure_image.original_image_path
    self.save
  end

  def get_160x160_thumbnail_image_url(return_default=true)
    if self.default_pic and self.default_pic != ""
      if ENV['S3_ENABLED']
        return get_thumbnail_url("/uploads/"+self.default_pic,160,160)
      else
        return self.default_pic
      end
    end

    if return_default == false
      return nil
    end

    return "/images/defaultThumb160x160.jpg"
  end

  def get_thumbnail_image_url(return_default=true,return_fullpath=false)
    if  self.default_pic and self.default_pic != ""
      if ENV['S3_ENABLED']
        return get_thumbnail_url("/uploads/"+self.default_pic,50,50)
      else
        return self.default_pic
      end
    end

    if return_default == false
      return nil
    end

    if return_fullpath
      return "http://"+DOMAIN_NAME+"/images/defaultThumb.jpg"
    end
      
    return "/images/defaultThumb.jpg"
    
    
  end

  def get_image_url(return_default=true)

    if self.default_pic and self.default_pic != ""
      if ENV['S3_ENABLED']

        return "http://s3.amazonaws.com/#{AWS_S3_BUCKET_NAME}/uploads/#{self.default_pic}"
      else
        return self.default_pic
      end
    end

    if return_default == false
      return nil
    end

    return ""
  end
  
  def update_picture(picture_list)
      inner_update_picture(picture_list,FigureImage,:figure_id,"figure")
  end
    
  def title
    return_title = self["title_"+$facebook.country_code.downcase]

    if return_title == "" || return_title == nil
      languages = ["US","TH","JP","KR","CN",]
      languages.each do |language|
        return_title = self["title_"+language.downcase]
        if return_title != "" and return_title != nil
          break
        end
      end
    end
    
    return return_title
  end
  
  def get_tags_column
    tags_name = []
    figure_tags = FigureTag.all(:conditions=>{:figure_id=>self.id})
    figure_tags.each do |ft|
      tag = Tag.first(:conditions=>{:id=>ft.tag_id})
      tags_name.push("<t>"+tag.name+"</t>")
    end
    tags_name.uniq!
    
    return_text = ""
    return_text = tags_name.join() if tags_name.length > 0
    return return_text
  end
end