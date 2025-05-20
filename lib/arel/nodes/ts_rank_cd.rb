# frozen_string_literal: true

module Arel
  module Nodes
    class TSRankCD < Arel::Nodes::Node
      
      attr_reader :tsvector, :tsquery, :normalization
      
      def initialize(tsvector, tsquery, normalization=nil)
        @tsvector = tsvector
        @tsquery = tsquery
        @normalization = normalization
      end

      def hash
        [@tsvector, @tsquery, @normalization].hash
      end

      def eql? other
        self.class == other.class &&
        self.tsvector == other.tsvector &&
        self.tsquery == other.tsquery &&
        self.normalization == other.normalization
      end
      alias :== :eql?

    end
  end
end