module WritepubEditor
  module WritepubTag
    
    class Em < Base
      
      def is_match
        @node.name.downcase == "em"
      end
     
      def transform
        
        return if remove_node_if_empty?
        
        @node.name = "i"
        @node.remove_all_attributes
      end
      
    end
    
  end
end