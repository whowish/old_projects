class KratooTagUpdater
 
  # Resque
  #
  #
  #
  @queue = :normal
  
  def self.perform(*tag_ids)
    
    batch_size = 100

    tag_ids.each { |tag_id|

      offset = 0
      while true
        kratoos = Kratoo.only(:all_tag_ids,:tag_ids,:title).where(:all_tag_ids=>tag_id).desc(:created_date).skip(offset).entries
        
        break if kratoos.length == 0
        
        
        kratoos.each { |kratoo|
          kratoo.organize_tags
        }
        
        offset += batch_size
      end
    }
  end
end