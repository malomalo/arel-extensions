# frozen_string_literal: true

module Arel
  module Nodes
    # PostgreSQL `&<`. Does the left range stop at or before the right one's upper bound?
    class NotExtendRightOf < InfixOperation
      def initialize(left, right)
        super(:"&<", left, right)
      end
    end
  end
end
