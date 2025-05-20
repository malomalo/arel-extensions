# frozen_string_literal: true

module Arel
  module Nodes
    class TSVector < Arel::Nodes::Node
      
      attr_reader :attribute, :language
      
      def initialize(attribute, language: nil)
        @attribute = attribute
        @language = Arel::Nodes.build_quoted(language) if language
      end

      def hash
        [@attribute, @language].hash
      end

      def eql? other
        self.class == other.class &&
        self.attribute == other.attribute &&
        self.language == other.language
      end
      alias :== :eql?
    end
  end
end