module WritepubEditor
  module Preprocessing
    
    class Img < Base
      
      def self.process(html)
        html.gsub(/<(img[^>]*[^\/])>/,'<\1 />')
      end
      
    end
    
  end
end