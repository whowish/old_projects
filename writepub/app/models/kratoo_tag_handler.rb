module KratooTagHandler
  def organize_tags
    
    self.all_tag_ids = []
    all_ancestors = []
    
    # loop each tag, retrieve all of its ancestors, and add them to all_tag_ids
    Tag.any_in(:_id=>self.tag_ids).each { |tag|

      if tag.alias_with_tag != nil
        tag = Tag.first(:conditions=>{:_id=>tag.alias_with_tag})
      end

      ancestors = get_ancestors(tag.id)
      
      self.all_tag_ids.push(tag.id)
      self.all_tag_ids += ancestors
      all_ancestors += ancestors
      
    }
    
    all_ancestors = all_ancestors.to_hash_keys { |v| true }

    tags = []
    # Reduce redundancy
    Tag.any_in(:_id=>self.tag_ids).each { |tag|
      
      original_tag_id = tag.id
      
      if tag.alias_with_tag != nil
        tag = Tag.first(:conditions=>{:_id=>tag.alias_with_tag})
      end

      if all_ancestors[tag.id] == true
        
      else
        tags.push(original_tag_id)
      end
      
    }
    
    self.all_tag_ids.uniq!
    self.tag_ids = tags.uniq
    
    self.save
  end
  
  private
  def get_ancestors(tag_id,check={})
    check[tag_id] = true
    
    tag = Tag.first(:conditions=>{:_id=>tag_id})
    
    return [] if tag == nil
    
    ancestors = []
    
    if tag.incomings
      ancestors += tag.incomings
      
      tag.incomings.each { |ancestor_id|
        next if check[ancestor_id] == true
        ancestors += get_ancestors(ancestor_id,check)
      }
    end
    
    return ancestors
  end
end