module WritepubEditor
  module WritepubTag
    
    class Text < Base
      
      def is_match
        @node.name.downcase == "text" \
        && @node.instance_of?(Nokogiri::XML::Text)
      end
     
      def transform
        
        if @node.content.gsub(/[ \t]/,"") == ""
          @node.remove
        end
        
      end
    end
    
  end
end