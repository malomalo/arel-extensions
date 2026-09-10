# frozen_string_literal: true

module Arel
  module Nodes
    # PostgreSQL `&>`. Does the left range start at or after the right one's lower bound?
    class NotExtendLeftOf < InfixOperation
      def initialize(left, right)
        super(:"&>", left, right)
      end
    end
  end
end
