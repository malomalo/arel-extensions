module Arel
  module Visitors
    class PostgreSQL
      private
      
      def column_for attr
        return nil if attr.is_a?(Arel::Attributes::Key)
        super
      end
      
      def visit_Arel_Nodes_Contains o, collector
        visit o.left, collector
        collector << ' @> '
        collector << quote(o.left.type_cast_for_database(o.right))
        collector
      end
      
      def visit_Arel_Nodes_ContainedBy o, collector
        visit o.left, collector
        collector << ' <@ '
        collector << quote(o.left.type_cast_for_database(o.right))
        collector
      end

      def visit_Arel_Nodes_Overlaps o, collector
        visit o.left, collector
        collector << ' && '
        collector << quote(o.left.type_cast_for_database(o.right))
        collector
      end
      
      def visit_Arel_Attributes_Key(o, collector, last_key = true)
        if o.relation.is_a?(Arel::Attributes::Key)
          visit_Arel_Attributes_Key(o.relation, collector, false)
          if last_key
            collector << o.name.to_s
            collector << "}'"
          else
            collector << o.name.to_s
            collector << ","
          end
        else
          visit(o.relation, collector)
          collector << "\#>>'{" << o.name.to_s
          collector << (last_key ? "}'" : ",")
        end
        collector
      end

      def visit_Arel_Nodes_HasKey(o, collector)
        right = o.right
        
        collector = visit o.left, collector
        
        collector << " ? " << quote(right.to_s)
        collector
      end
      
      def visit_Arel_Attributes_Cast(o, collector)
        collector << "("
        visit(o.relation, collector)
        collector << ")::#{o.name}"
        collector
      end

    end
  end
end