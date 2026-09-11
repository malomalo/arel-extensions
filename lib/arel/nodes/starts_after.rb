# frozen_string_literal: true

module Arel
  module Nodes
    # PostgreSQL `>>`. Does the left range start after the right one ends — every element higher,
    # with no overlap?
    class StartsAfter < InfixOperation
      def initialize(left, right)
        super(:">>", left, right)
      end
    end
  end
end
