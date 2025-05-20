# frozen_string_literal: true

module Arel
  module Visitors
    class ToSql

      def visit_Arel_Attributes_Relation(o, collector)
        visit(o.relation, collector)
      end

    end
  end
end