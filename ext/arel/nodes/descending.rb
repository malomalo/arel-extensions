module Arel
  module Nodes
    class Descending < Ordering

      attr_accessor :nulls

      def initialize expr, nulls=nil
        super(expr)
        @nulls = nulls
      end

    end

  end
end