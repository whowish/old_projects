module WritepubEditor
  module Preprocessing
    
    class Br < Base
      
      def self.process(html)
        html.gsub(/<(br([^>]*[^\/])?)>/i,'<\1 />')
      end
      
    end
    
  end
end