module WritepubEditor
  module WritepubTag
    class Base
      
      def initialize(node)
        @node = node
      end
      
      def is_match
        raise 'Not implemented'
      end
      
      def transform
        raise 'Not implemented'
      end
      
      def remove_node_if_empty?
        
        if @node.children.length == 0
          @node.remove
          return true
        end
        
        return false
      end
      
    end
  end
end