# frozen_string_literal: true

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

      # Path segments are emitted as a quoted `array[...]` rather than
      # interpolated into a `'{...}'` array literal, so a segment can never
      # break out of the path and inject SQL (GHSA-75hc-9q9v-9cv2). PostgreSQL
      # const-folds the array back to `'{a,b}'::text[]`, so expression indexes
      # on the literal form still match.
      def visit_Arel_Attributes_Key(o, collector)
        keys = []
        node = o
        while node.is_a?(Arel::Attributes::Key)
          keys.unshift(quote(node.name.to_s))
          node = node.relation
        end

        visit(node, collector)
        collector << " #> array[" << keys.join(',') << "]"
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

      # A type name can't be bound or quoted, so only allow something that
      # actually looks like one -- optionally schema qualified, with a modifier
      # and/or array suffix. Keeps user input from reaching the SQL as-is.
      CAST_TYPE = /\A
        [a-z_][a-z0-9_]*(\.[a-z_][a-z0-9_]*)?  # type, optionally schema qualified
        (\(\d+(\s*,\s*\d+)?\))?                # "varchar(255)", "numeric(10,2)"
        (\ [a-z]+)*                            # "timestamp with time zone"
        (\(\d+(\s*,\s*\d+)?\))?                # "character varying(255)"
        (\[\])*                                # "int[]"
      \z/xi
      
      def visit_Arel_Attributes_Cast(o, collector)
        type = o.name.to_s
        raise ArgumentError, "invalid cast type: #{type.inspect}" unless CAST_TYPE.match?(type)

        collector << "("
        visit(o.relation, collector)
        collector << ")::#{type}"
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

      def visit_Arel_Nodes_HexEncodedBinaryValue(o, collector)
        collector << quote("\\x" + o.expr)
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
