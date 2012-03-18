module KratooSunspot
  def self.included(base)
    base.class_eval do
      
      
      include Sunspot::Mongoid
      searchable do
        text :title
        text :content, :stored => true do
          
          if self.content != nil and self.content.text != nil
            self.content.text
          else
            ""
          end
        end
        
        string :id, :stored=>true
        string :title, :stored => true
        string :all_tag_ids, :multiple => true, :references => Tag
        string :tag_ids, :multiple => true, :references => Tag
        time :created_date, :trie => true
    
      end
  
  
    end
  end

end