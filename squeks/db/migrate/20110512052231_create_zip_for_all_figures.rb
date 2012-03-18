class CreateZipForAllFigures < ActiveRecord::Migration

  def self.up
    begin
    require 'zip/zip'
    require 'open-uri'
    
    # generate zip file
    Figure.all.each { |figure|
      
      filename = "picture_#{figure.id}.zip"
      tmp_file = Tempfile.new(filename)

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
      
      if count > 0
        AWS::S3::S3Object.store("uploads/#{filename}", File.open(tmp_file.path,'rb'), AWS_S3_BUCKET_NAME,:access=>:public_read)
        figure.zip_file_path = filename
        puts "#{figure.id} OK"
      else
        puts "#{figure.id} NO IMAGE"
        figure.zip_file_path = nil
      end
      
      figure.save
      
      tmp_file.close
      
      
    }
  rescue
    end
  end

  def self.down
  end
end
