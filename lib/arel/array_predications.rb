# frozen_string_literal: true

module Arel
  module ArrayPredications

    # Used by both JSON and ARRAY so it doesn't try to cast to array
    def contained_by(value)
      Arel::Nodes::ContainedBy.new(self, value)
    end

    def excludes(value)
      Arel::Nodes::Excludes.new(self, value)
    end

  end
end
