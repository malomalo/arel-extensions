module Arel
  module ArrayPredications
    
    # Used by both JSON and ARRAY so it doesn't try to cast to array
    def contains(value)
      Arel::Nodes::Contains.new(self, value)
    end
    
    # Used by both JSON and ARRAY so it doesn't try to cast to array
    def contained_by(value)
      Arel::Nodes::ContainedBy.new(self, value)
    end
    
    def overlaps(*values)
      values = values[0] if values.size == 1 && values[0].is_a?(Array)
      Arel::Nodes::Overlaps.new(self, values)
    end
    
  end
end