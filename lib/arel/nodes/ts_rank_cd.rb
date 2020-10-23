module Arel
  module Nodes
    class TSRankCD < Arel::Nodes::Node
      
      attr_reader :tsvector, :tsquery, :normalization
      
      def initialize(tsvector, tsquery, normalization=nil)
        @tsvector = tsvector
        @tsquery = tsquery
        @normalization = normalization
      end

    end
  end
end