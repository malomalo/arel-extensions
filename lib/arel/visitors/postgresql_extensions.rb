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

      def visit_Arel_Nodes_Excludes o, collector
        collector << 'NOT ('
        visit o.left, collector
        collector << ' @> '
        visit o.right, collector
        collector << ')'
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
        if o.normalization
          collector << ', '
          visit(o.normalization, collector)
        end
        collector << ')'
        collector
      end

      def visit_Arel_Nodes_BinaryValue(o, collector)
        collector << quote(@connection.escape_bytea(o.expr))
        collector
      end

      def visit_Arel_Nodes_Intersects o, collector
        visit(Arel::Nodes::NamedFunction.new('ST_Intersects', [ o.left, o.right ]), collector)
        collector
      end

      def visit_Arel_Nodes_Within o, collector
        visit(Arel::Nodes::NamedFunction.new('ST_Within', [ o.left, o.right ]), collector)
        collector
      end

      def visit_Arel_Nodes_Geometry o, collector
        collector << quote(o.value.as_binary.each_byte.map { |b| b.to_s(16).rjust(2, '0') }.join)
        collector
      end

    end
  end
end
