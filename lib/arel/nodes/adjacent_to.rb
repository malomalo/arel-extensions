# frozen_string_literal: true

module Arel
  module Nodes
    # PostgreSQL `-|-`. Do the two ranges abut — touching, with no gap and no overlap?
    class AdjacentTo < InfixOperation
      def initialize(left, right)
        super(:"-|-", left, right)
      end
    end
  end
end
