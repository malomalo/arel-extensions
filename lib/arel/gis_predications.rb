module Arel
  module GISPredications
    
    def within(bounds)
      Arel::Nodes::Within.new(self, bounds)
    end

  end
end
