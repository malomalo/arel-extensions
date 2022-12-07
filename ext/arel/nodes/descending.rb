module Arel
  module Nodes
    class Descending < Ordering

      attr_accessor :nulls

      def initialize expr, nulls=nil
        super(expr)
        @nulls = nulls
      end

      def reverse
        reverse_nulls = if nulls == :nulls_first
          :nulls_last
        elsif nulls
          :nulls_first
        else
          nil
        end
        
        Ascending.new(expr, reverse_nulls)
      end
      
    end

  end
end