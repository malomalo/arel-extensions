# frozen_string_literal: true

module Arel
  module Nodes
    # PostgreSQL `&<`. Does the left range end by the time the right one does — no later than its
    # upper bound? Overlap is allowed.
    class EndsBy < InfixOperation
      def initialize(left, right)
        super(:"&<", left, right)
      end
    end
  end
end
