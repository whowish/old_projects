module ImageHelper
  include ThumbnailismHelper

  def inner_update_picture(picture_list,image_class,field_id,prefix)
    last_image_id = image_class.maximum(:id)
       if(last_image_id != nil)
        img_id = last_image_id + 1
      else
        img_id = 1
      end
      
      images = image_class.all(:conditions=>{field_id=>id},:order=>"ordered_number asc")
      images_name = images.map {|p| p.original_image_path}
     
      temp_images = picture_list.split(",")
      
      temp_images_name = []
      
      temp_images.each do |temp_image|
        temp_images_name.push(File.basename(temp_image))
      end

      images.each do |image|
        if !temp_images_name.include?(image.original_image_path)
          delete_image( image.original_image_path)
          image.destroy
        end
      end
      
      images_after_del = image_class.all(:conditions=>{field_id=>id},:order=>"ordered_number asc")
      order = 0
      images_after_del.each do |image|
        image.ordered_number = order
        image.save
        order = order + 1
      end
      
      temp_images_name.each do |temp_image|
        if !images_name.include?(temp_image)
         
          ext = File.extname( temp_image ).sub( /^\./, "" ).downcase
          
          new_img_name = prefix+"_" + id.to_s + "_" + img_id.to_s + "." + ext
      
          begin
            image_copy(temp_image,new_img_name)
          rescue
          end
        
          begin
            THUMBNAIL_SIZES.each { |size|
              tokens = size.split('x')
              make_thumbnail(new_img_name,tokens[0].to_i,tokens[1].to_i)
            }
          rescue
          end
          
          img = image_class.new
          img[field_id] = id
          img.ordered_number = order
          img.original_image_path = new_img_name
          img.save
          
          img_id = img_id + 1
          order = order + 1
          delete_image(temp_image)

        end
      end
  end
  
end