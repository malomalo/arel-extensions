module Arel
  module TSPredications
    
    def ts_query(expression, language=nil)
      vector = Arel::Nodes::TSVector.new(self, language)
      query = Arel::Nodes::TSQuery.new(expression, language)
      
      Arel::Nodes::TSMatch.new(vector, query)
    end
    
  end
end