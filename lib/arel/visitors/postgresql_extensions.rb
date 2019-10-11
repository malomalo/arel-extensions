module Arel
  module Visitors
    class PostgreSQL
      private
      
      def column_for attr
        return nil if attr.is_a?(Arel::Attributes::Key)
        super
      end
      
      def visit_Arel_Nodes_Ascending o, collector
        case o.nulls
        when :nulls_first then visit(o.expr, collector) << ' ASC NULLS FIRST'
        when :nulls_last  then visit(o.expr, collector) << ' ASC NULLS LAST'
        else visit(o.expr, collector) << ' ASC'
        end
      end

      def visit_Arel_Nodes_Descending o, collector
        case o.nulls
        when :nulls_first then visit(o.expr, collector) << ' DESC NULLS FIRST'
        when :nulls_last  then visit(o.expr, collector) << ' DESC NULLS LAST'
        else visit(o.expr, collector) << ' DESC'
        end
      end
      
      def visit_Arel_Nodes_RandomOrdering o, collector
        collector << "RANDOM()"
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

      def visit_Arel_Nodes_Excludes o, collector
        collector << 'NOT ('
        visit o.left, collector
        collector << ' @> '
        collector << quote(o.left.type_cast_for_database(o.right))
        collector << ')'
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
          collector << "\#>'{" << o.name.to_s
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

      def visit_Arel_Nodes_HasKeys(o, collector)
        right = o.right
        
        collector = visit o.left, collector
        
        collector << " ?& array[" << Array(right).map { |v| quote(v.to_s) }.join(',') << "]"
        collector
      end
      
      def visit_Arel_Nodes_HasAnyKey(o, collector)
        right = o.right
        
        collector = visit o.left, collector
        
        collector << " ?| array[" << Array(right).map { |v| quote(v.to_s) }.join(',') << "]"
        collector
      end
      
      def visit_Arel_Attributes_Cast(o, collector)
        collector << "("
        visit(o.relation, collector)
        collector << ")::#{o.name}"
        collector
      end
      
      def visit_Arel_Nodes_TSMatch(o, collector)
        visit o.left, collector
        collector << ' @@ '
        visit o.right, collector
        collector
      end
      
      def visit_Arel_Nodes_TSVector(o, collector)
        collector << 'to_tsvector('
        if o.language
          visit(o.language, collector) 
          collector << ', '
        end
        visit(o.attribute, collector) 
        collector << ')'
        collector
      end
      
      def visit_Arel_Nodes_TSQuery(o, collector)
        collector << 'to_tsquery('
        if o.language
          visit(o.language, collector) 
          collector << ', '
        end
        visit(o.expression, collector) 
        collector << ')'
        collector
      end
      
      def visit_Arel_Nodes_TSRank(o, collector)
        collector << 'ts_rank('
        visit(o.tsvector, collector) 
        collector << ', '
        visit(o.tsquery, collector)
        collector << ')'
        collector
      end
      
      def visit_Arel_Nodes_TSRankCD(o, collector)
        collector << 'ts_rank_cd('
        visit(o.tsvector, collector) 
        collector << ', '
        visit(o.tsquery, collector)
        collector << ')'
        collector
      end
      
      def visit_Arel_Nodes_HexEncodedBinary(o, collector)
        collector << "E'\\\\x"
        collector << o.expr
        collector << "'"
        collector
      end

      def visit_Arel_Nodes_Within o, collector
        envelope = if o.right.is_a?(Arel::Nodes::HexEncodedBinary)
          Arel::Nodes::NamedFunction.new('ST_GeomFromEWKB', [o.right])
        elsif o.right.is_a?(Arel::Nodes::Quoted) && o.right.expr.is_a?(String)
          Arel::Nodes::NamedFunction.new('ST_GeomFromEWKT', [o.right])
        elsif o.right.is_a?(Arel::Nodes::Quoted) && o.right.expr.is_a?(Hash)
          Arel::Nodes::NamedFunction.new('ST_GeomFromGeoJSON', [Arel::Nodes.build_quoted(o.right.expr.to_json)])
        else
          raise 'within error'
        end

        visit(Arel::Nodes::NamedFunction.new('ST_Within', [o.left, envelope]), collector)
        collector
      end

    end
  end
end
