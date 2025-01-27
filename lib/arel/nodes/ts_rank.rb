module Arel
  module Nodes
    class TSRank < Arel::Nodes::Node
      
      attr_reader :tsvector, :tsquery
      
      def initialize(tsvector, tsquery)
        @tsvector = tsvector
        @tsquery = tsquery
      end

      def hash
        [@tsvector, @tsquery].hash
      end

      def eql? other
        self.class == other.class &&
        self.tsvector == other.tsvector &&
        self.tsquery == other.tsquery
      end
      alias :== :eql?

    end
  end
end