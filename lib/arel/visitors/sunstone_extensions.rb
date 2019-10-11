module Arel
  module Visitors
    class Sunstone
      private

      def visit_Arel_Nodes_Ascending o, collector
        hash = visit(o.expr, collector)
        
        case o.nulls
        when :nulls_first
          add_to_bottom_of_hash_or_array(hash, {asc: :nulls_first})
        when :nulls_last
          add_to_bottom_of_hash_or_array(hash, {asc: :nulls_last})
        else
          add_to_bottom_of_hash_or_array(hash, :asc)
        end
        
        hash
      end

      def visit_Arel_Nodes_Descending o, collector
        hash = visit(o.expr, collector)
        
        case o.nulls
        when :nulls_first
          add_to_bottom_of_hash_or_array(hash, {desc: :nulls_first})
        when :nulls_last
          add_to_bottom_of_hash_or_array(hash, {desc: :nulls_last})
        else
          add_to_bottom_of_hash_or_array(hash, :desc)
        end
        
        hash
      end
      
      def visit_Arel_Nodes_RandomOrdering o, collector
        :random
      end

      def visit_Hash o, collector
        rvalue = {}
        o.each do |key, value|
          rvalue[visit(key, collector)] = visit(value, collector)
        end
        rvalue
      end
      alias :visit_String                :literal
      def visit_Symbol o, collector
        o.to_s
      end

      def visit_Arel_Nodes_Contains o, collector
        key = visit(o.left, collector)
        value = { contains: visit(o.right, collector) }
        
        if key.is_a?(Hash)
          add_to_bottom_of_hash(key, value)
        else
          { key => value }
        end
      end

      def visit_Arel_Nodes_HexEncodedBinary(o, collector)
        o.expr
      end
      
      def visit_Arel_Nodes_Within o, collector
        key = visit(o.left, collector)
        value = { within: visit(o.right, collector) }

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
      
      def visit_Arel_Nodes_Overlaps o, collector
        key = visit(o.left, collector)
        value = { overlaps: o.left.type_cast_for_database(o.right) }
        
        if key.is_a?(Hash)
          add_to_bottom_of_hash_or_array(key, value)
          key
        else
          {key => value}
        end
      end

      def visit_Arel_Nodes_NotOverlaps o, collector
        key = visit(o.left, collector)
        value = { not_overlaps: o.left.type_cast_for_database(o.right) }
        
        if key.is_a?(Hash)
          add_to_bottom_of_hash_or_array(key, value)
          key
        else
          {key => value}
        end
      end
      
      def visit_Arel_Nodes_HasKey o, collector
        key = visit(o.left, collector)
        value = {has_key: (o.right.nil? ? nil : o.right.to_s)}
        
        if key.is_a?(Hash)
          add_to_bottom_of_hash(key, value)
        else
          { key => value }
        end
      end
      
      def visit_Arel_Nodes_HasKeys o, collector
        key = visit(o.left, collector)
        value = {has_keys: Array(o.right).map(&:to_s)}
        
        if key.is_a?(Hash)
          add_to_bottom_of_hash(key, value)
        else
          { key => value }
        end
      end
      
      def visit_Arel_Nodes_HasAnyKey o, collector
        key = visit(o.left, collector)
        value = { has_any_key: visit(Array(o.right), collector) }
        
        if key.is_a?(Hash)
          add_to_bottom_of_hash(key, value)
        else
          { key => value }
        end
      end
      
    end
  end
end