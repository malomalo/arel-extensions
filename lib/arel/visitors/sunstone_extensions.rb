module Arel
  module Visitors
    class Sunstone
      private
      
      def visit_Arel_Nodes_Contains o, collector
        key = visit(o.left, collector)
        value = { :contains => visit(o.right, collector) }
        
        if key.is_a?(Hash)
          add_to_bottom_of_hash(key, value)
        else
          key = key.to_s.split('.')
          hash = { key.pop => value }
          while key.size > 0
            hash = { key.pop => hash }
          end
          hash
        end
      end
      
    end
  end
end