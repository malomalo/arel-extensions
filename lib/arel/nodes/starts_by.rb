# frozen_string_literal: true

module Arel
  module Nodes
    # PostgreSQL `&>`. Does the left range start no earlier than the right one does? Overlap is
    # allowed.
    class StartsBy < InfixOperation
      def initialize(left, right)
        super(:"&>", left, right)
      end
    end
  end
end
