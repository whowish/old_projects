class KratooTagMerger

  # Resque
  #
  #
  #
  @queue = :normal

  def self.perform(from_tag_id,to_tag_id)
    
    batch_size = 100

    offset = 0
    while true
      kratoos = Kratoo.only(:tag_ids).where(:tag_ids=>from_tag_id).desc(:created_date).skip(offset).entries

      break if kratoos.length == 0
      
      
      kratoos.each { |kratoo|
        kratoo.pull_all(:tag_ids,[from_tag_id])
        kratoo.add_to_set(:tag_ids,to_tag_id)
        kratoo.organize_tags
      }
      
      offset += batch_size
    end
  end
end