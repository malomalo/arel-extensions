# frozen_string_literal: true

module Arel
  module Nodes
    class TSQuery < Arel::Nodes::Node
      
      attr_reader :expression, :language
      
      def initialize(expression, language: nil)
        @expression = Arel::Nodes.build_quoted(expression)
        @language = Arel::Nodes.build_quoted(language) if language
      end

      def hash
        [@expression, @language].hash
      end

      def eql? other
        self.class == other.class &&
        self.expression == other.expression &&
        self.language == other.language
      end
      alias :== :eql?

    end
  end
end