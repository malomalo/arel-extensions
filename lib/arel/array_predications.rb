# frozen_string_literal: true

module Arel
  module ArrayPredications

    # Used by both JSON and ARRAY so it doesn't try to cast to array — callers
    # there pre-wrap the value themselves.
    #
    # A Ruby Range is the exception: it has no other reading, and leaving it
    # unquoted made `contained_by` the one range predicate that could not take
    # one (`contains` and `overlaps` come from Arel core, which quotes through
    # the attribute). On a range column the attribute's type casts it to a
    # PostgreSQL range literal.
    def contained_by(value)
      value = Arel::Nodes.build_quoted(value, self) if value.is_a?(::Range)
      Arel::Nodes::ContainedBy.new(self, value)
    end

    def excludes(value)
      Arel::Nodes::Excludes.new(self, value)
    end

  end
end
