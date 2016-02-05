module Arel
  module ArrayPredications
    
    def contains(*values)
      values = values[0] if values.size == 1 && values[0].is_a?(Array)
      Arel::Nodes::Contains.new(self, values)
    end
    
    def contained_by(*values)
      values = values[0] if values.size == 1 && values[0].is_a?(Array)
      Arel::Nodes::ContainedBy.new(self, values)
    end
    
    def overlaps(*values)
      values = values[0] if values.size == 1 && values[0].is_a?(Array)
      Arel::Nodes::Overlaps.new(self, values)
    end
    
  end
end