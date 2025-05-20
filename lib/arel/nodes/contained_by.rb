# frozen_string_literal: true

module Arel
  module Nodes
    class ContainedBy < InfixOperation
      def initialize(left, right)
        super(:"<@", left, right)
      end
    end
  end
end
