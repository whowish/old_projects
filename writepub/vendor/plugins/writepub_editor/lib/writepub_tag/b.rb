module WritepubEditor
  module WritepubTag
    
    class B < Base
      
      def is_match
        @node.name.downcase == "b"
      end
     
      def transform
        
        return if remove_node_if_empty?
        
        @node.name = "b"
        @node.remove_all_attributes
      end
    end
    
  end
end