module WritepubEditor
  module WritepubTag
    
    class I < Base
      
      def is_match
        @node.name.downcase == "i"
      end
     
      def transform
        
        return if remove_node_if_empty?
        
        @node.name = "i"
        @node.remove_all_attributes
      end
    end
    
  end
end