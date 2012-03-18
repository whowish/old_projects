module WritepubEditor
  module WritepubTag
    
    class SpanItalic < Base
      
      def is_match
        @node.name.downcase == "span" \
        && @node.has_attribute?("style") \
        && @node.get_attribute("style").downcase.match(/font\-style:[^;]*italic/i) != nil
      end
     
      def transform
        
        return if remove_node_if_empty?
        
        @node.name = "i"
        @node.remove_all_attributes
      end
    end
    
  end
end