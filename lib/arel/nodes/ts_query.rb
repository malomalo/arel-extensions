module Arel
  module Nodes
    class TSQuery < Arel::Nodes::Node
      
      attr_reader :expression, :language
      
      def initialize(expression, language: nil)
        @expression = Arel::Nodes.build_quoted(expression)
        @language = Arel::Nodes.build_quoted(language) if language
      end

    end
  end
end