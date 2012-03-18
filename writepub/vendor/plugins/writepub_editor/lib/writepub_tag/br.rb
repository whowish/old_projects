module WritepubEditor
  module WritepubTag
    
    class Br < Base
      
      def is_match
        @node.name.downcase == "br"
      end
     
      def transform
        @node.name = "br"
        @node.remove_all_attributes
      end
    end
    
  end
end