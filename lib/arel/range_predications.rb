# frozen_string_literal: true

module Arel
  # PostgreSQL's positional range operators. Each takes a range and answers a
  # question about where the two sit relative to one another, which `contains`,
  # `overlaps` and `contained_by` cannot express.
  #
  # Operands are quoted through the attribute the way Arel core's `overlaps`
  # does, so a Ruby Range works and an already-built node passes through.
  module RangePredications

    # <<
    def ends_before(value)
      Arel::Nodes::EndsBefore.new(self, Arel::Nodes.build_quoted(value, self))
    end

    # >>
    def starts_after(value)
      Arel::Nodes::StartsAfter.new(self, Arel::Nodes.build_quoted(value, self))
    end

    # &<
    def ends_by(value)
      Arel::Nodes::EndsBy.new(self, Arel::Nodes.build_quoted(value, self))
    end

    # &>
    def starts_by(value)
      Arel::Nodes::StartsBy.new(self, Arel::Nodes.build_quoted(value, self))
    end

    # -|-
    def adjacent_to(value)
      Arel::Nodes::AdjacentTo.new(self, Arel::Nodes.build_quoted(value, self))
    end

  end
end
