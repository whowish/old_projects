require 'fileutils'

class RichContent
  include Mongoid::Document
  
  field :text, :type=>String, :default=>""
  field :images, :type=>Array, :default=>[]
  field :html, :type=>String, :default=>""
  embedded_in :rich_content, :polymorphic => true
  
  def set_html(html)

    
    doc = WritepubEditor::Base.new(html)
    
    self.html = doc.to_s
    self.text = doc.text
    
    update_images(doc.get_images)

  end

  private
  def update_images(new_images)
    
    previous_images = self.images

    deleteds = previous_images - new_images
    deleteds.each { |img|
      FileUtils.remove(File.join(Rails.root, "public", CGI.unescape(img)), :force=>true)
      
      #puts "Delete #{img}"
    }
    
    ensure_path(File.join(Rails.root, "public", "/uploads/images/dummy.jpg"))
    
    self.images = self.images - deleteds
    
    news =  new_images - previous_images
    news.each { |img|

        new_path = "/uploads/images/#{File.basename(img)}"
        
        self.html.gsub!(img, new_path)
        
        Rails.logger.info { "Add #{File.basename(img)}" }
        
        begin
          FileUtils.copy(File.join(Rails.root, "public", CGI.unescape(img)), 
                          File.join(Rails.root, "public", CGI.unescape(new_path)))
                          
          self.images.push(new_path)
          
        rescue Exception=>e
          Rails.logger.debug { e.to_s_with_trace }
        end
        
       FileUtils.remove(File.join(Rails.root, "public", CGI.unescape(img)), :force=>true)
    }
    
  end
  
  def ensure_path(dest)
    
    dir = File.dirname(dest)

    token_dirs = dir.split('/')
    root_d = token_dirs[0]
    
    token_dirs[1..-1].each {|d|
    
      this_path = "#{root_d}/#{d}"
      if !File.directory?(this_path)
        Dir.mkdir(this_path)
        File.chmod(0777, this_path)   
      end
      
      root_d = this_path
    }

  end
  
end