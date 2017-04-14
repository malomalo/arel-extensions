module Arel
  module Visitors
    class Sunstone
      private
      
      def visit_Arel_Nodes_Contains o, collector
        key = visit(o.left, collector)
        value = { contains:  visit(o.right, collector) }
        
        if key.is_a?(Hash)
          add_to_bottom_of_hash(key, value)
        else
          { key => value }
        end
      end

      def visit_Arel_Nodes_Excludes o, collector
        key = visit(o.left, collector)
        value = { excludes: o.left.type_cast_for_database(o.right) }
        
        if key.is_a?(Hash)
          add_to_bottom_of_hash(key, value)
        else
          { key => value }
        end
      end
      
    end
  end
end