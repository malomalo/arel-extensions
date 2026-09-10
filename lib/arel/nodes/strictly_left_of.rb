# frozen_string_literal: true

module Arel
  module Nodes
    # PostgreSQL `<<`. Is the left range strictly left of the right one — every element lower,
    # with no overlap?
    class StrictlyLeftOf < InfixOperation
      def initialize(left, right)
        super(:"<<", left, right)
      end
    end
  end
end
