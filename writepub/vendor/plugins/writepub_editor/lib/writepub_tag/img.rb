module WritepubEditor
  module WritepubTag
    
    class Img < Base
      
      def is_match
        @node.name.downcase == "img" \
        && @node.has_attribute?("src")
      end
     
      def transform
        @node.name = "img"
        @node.remove_all_attributes(:src)
        
        src = @node.get_attribute("src")
        @node.set_attribute("src", src.sub(Regexp.new("https?:\/\/(www\.)?#{DOMAIN_NAME}"),""))
      end
    end
    
  end
end