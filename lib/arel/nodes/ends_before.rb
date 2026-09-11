# frozen_string_literal: true

module Arel
  module Nodes
    # PostgreSQL `<<`. Does the left range end before the right one starts — every element lower,
    # with no overlap?
    class EndsBefore < InfixOperation
      def initialize(left, right)
        super(:"<<", left, right)
      end
    end
  end
end
