module WritepubEditor
  module WritepubTag
    
    class A < Base
      
      def is_match
        @node.name.downcase == "a" \
        && @node.has_attribute?("href") \
        && @node.get_attribute("href").match(/^(https?|ftp)/i) != nil
      end
     
      def transform
        
        return if remove_node_if_empty?
        
        @node.name = "a"
        @node.remove_all_attributes(:href)
      end
    end
    
  end
end