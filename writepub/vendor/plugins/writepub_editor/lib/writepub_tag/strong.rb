module WritepubEditor
  module WritepubTag
    
    class Strong < Base
      
      def is_match
        @node.name.downcase == "strong"
      end
     
      def transform
        
        return if remove_node_if_empty?
        
        @node.name = "b"
        @node.remove_all_attributes
      end
    end
    
  end
end