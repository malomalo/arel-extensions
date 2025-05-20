# frozen_string_literal: true

module Arel
  module TSPredications
    
    def ts_query(expression, language=nil)
      vector = Arel::Nodes::TSVector.new(self, language: language)
      query = Arel::Nodes::TSQuery.new(expression, language: language)
      
      Arel::Nodes::TSMatch.new(vector, query)
    end
    
  end
end
