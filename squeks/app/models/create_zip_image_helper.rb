class CreateZipImageHelper
  attr_accessor :figure_id
  
  def initialize(figure_id)
    @figure_id = figure_id
  end
  
  def perform
    require 'zip/zip'
    require 'open-uri'
    
    figure = Figure.first(:conditions=>{:id=>figure_id})
    
    return if !figure
    
    new_file_name = "picture_#{figure.id}_s#{rand(100)}.zip"
    
    while new_file_name == figure.zip_file_path 
      new_file_name = "picture_#{figure.id}_s#{rand(100)}.zip"
    end
    
    tmp_file = Tempfile.new(new_file_name)

    count = 0
    delete_entries = []
    Zip::ZipOutputStream.open(tmp_file.path) { |zipfile|
      
      FigureImage.all(:conditions=>{:figure_id=>figure.id}).each { |image|
      
        url = "http://s3.amazonaws.com/#{AWS_S3_BUCKET_NAME}/uploads/#{image.original_image_path}"
        
        begin
          
          zipfile.put_next_entry(image.original_image_path)
          open(url) {|f_img| zipfile.print f_img.read }
          count += 1
        rescue
          delete_entries.push(image.original_image_path)
        end
        
      }
      
    }
    
    #delete entries
#    Zip::ZipFile.open(tmp_file) { |zipfile|
#      delete_entries.each { |e| zipfile.remove(e)}
#    }
    
    old_file_name = figure.zip_file_path 
    
    if count > 0
      AWS::S3::S3Object.store("uploads/#{new_file_name}", File.open(tmp_file.path,'rb'), AWS_S3_BUCKET_NAME,:access=>:public_read)
      figure.zip_file_path = new_file_name
    else
      figure.zip_file_path = nil
    end
    
    figure.save
    tmp_file.close
    
    if old_file_name != nil and old_file_name != ""
      begin
        AWS::S3::S3Object.delete("uploads/#{old_file_name}", AWS_S3_BUCKET_NAME)
      rescue
      end
    end

  end
end