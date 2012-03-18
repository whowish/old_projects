class AdminPartnerController < AdminController
   include ThumbnailismHelper
  
  def add
    partner = Partner.new()
    partner.country = params[:country]
    partner.description = params[:desc]
    partner.name = params[:name]
    partner.url = params[:url]
    partner.ordered_number = Partner.count+1
    partner.save
    render :json=>{:ok=>true,:partner_view=> render_to_string(:partial=>"/admin_partner/partner_unit",:locals=>{:partner=>partner})}
  end
  
  def edit
    partner = Partner.first(:conditions=>{:id=>params[:id]})
    partner.country = params[:country]
    partner.description = params[:desc]
    partner.name = params[:name]
    partner.url = params[:url]
    partner.ordered_number = params[:ordered_number]
    partner.save
    render :json=>{:ok=>true}
  end
  
  def delete
    partner = Partner.first(:conditions=>{:id=>params[:id]})
    partner.destroy
    render :json=>{:ok=>true}
  end
  
  def upload_image
    
    partner = Partner.first(:conditions=>{:id=>params[:partner_id]})
    
    ok, filename, error_message = inner_upload_image(params[:Filedata],partner)
    
    #absolutely necessary, otherwise the browser will force download
    response.headers['Content-type'] = 'text/plain; charset=utf-8'
    
    render :json=>{:ok=>ok,:filename=>filename,:error_message=>error_message}
  end
  
  def inner_upload_image(image_data,partner)
 
    return false, nil, "The image cannot exceed 8MB" if image_data.size > 8000000

    ext = File.extname( image_data.original_filename ).sub( /^\./, "" ).downcase

    if !["jpg","jpeg","gif","png"].include?(ext)
      return false, nil, "The extension (#{ext}) is not allowed."
    end
    
    filename = "partner_#{partner.id.to_s}-#{rand(100)}."+ext
    
    begin
      if ENV['S3_ENABLED']
        
        AWS::S3::S3Object.store(get_server_path_of(filename), image_data.read, AWS_S3_BUCKET_NAME,:access=>:public_read)

      else
        
        File.open(RAILS_ROOT+"/public/uploads/#{filename}", "wb") { |f| 
          f.write(image_data.read) 
        }
        
        File.chmod(0777, get_server_path_of("/uploads/#{filename}")) 
        
        if partner.original_image_path != nil and partner.original_image_path != ""
          begin
            delete_image(partner.original_image_path)
          rescue
          end
        end
        
        partner.original_image_path = filename
        partner.save
      end
      
      return true, "/uploads/#{filename}", nil
    rescue Exception=>e
      
      if filename != ""
        begin
          delete_image(filename)
        rescue Exception=>ex
        end
      end
      
      return false, nil, "The uploading has failed. Please try again. #{e.to_s_with_trace}"
    end
 
  end
end
