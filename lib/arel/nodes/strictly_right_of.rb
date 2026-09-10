# frozen_string_literal: true

module Arel
  module Nodes
    # PostgreSQL `>>`. Is the left range strictly right of the right one — every element higher,
    # with no overlap?
    class StrictlyRightOf < InfixOperation
      def initialize(left, right)
        super(:">>", left, right)
      end
    end
  end
end
