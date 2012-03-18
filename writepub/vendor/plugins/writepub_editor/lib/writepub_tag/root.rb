module WritepubEditor
  module WritepubTag
    
    class Root < Base
      
      def is_match
        @node.name.downcase == "root"
      end
     
      def transform
        
      end
      
    end
    
  end
end