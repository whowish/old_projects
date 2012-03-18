class RemoveDuplicateTags < ActiveRecord::Migration
  def self.up
    delete_tag_ids = {}
    Tag.all.each { |tag|
    
      next if delete_tag_ids[tag.id]
    
      Tag.all(:conditions=>{:name=>tag.name}).each { |duplicate_tag|
        next if duplicate_tag.id == tag.id
        
        FigureTag.all(:conditions=>{:tag_id=>duplicate_tag.id}).each { |figure_tag|
          figure_tag.tag_id = tag.id
          figure_tag.save
        }
        
        duplicate_tag.destroy
        
        delete_tag_ids[duplicate_tag.id] = true
      }
      
      if FigureTag.count(:conditions=>{:tag_id=>tag.id}) == 0
        tag.destroy
      end
    }
  end

  def self.down
  end
end
