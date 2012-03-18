module WritepubEditor
  module WritepubTag
    
    class Youtube < Base
      
      def is_match
        @node.name.downcase == "iframe" \
        && @node.has_attribute?("src") \
        && (@node.get_attribute("src").match(/^https?:\/\/(www.)?youtube.com\//i) != nil)
      end
     
      def transform
        @node.name = "iframe"
        @node.remove_all_attributes(:allowfullscreen,:width,:height,:frameBorder,:src)  
      end
    end
    
  end
end