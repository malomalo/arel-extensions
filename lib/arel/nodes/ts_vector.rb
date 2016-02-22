module Arel
  module Nodes
    class TSVector < Arel::Nodes::Node
      
      attr_reader :attribute, :language
      
      def initialize(attribute, language)
        @attribute = attribute
        @language = Arel::Nodes.build_quoted(language) if language
      end
      
    end
  end
end