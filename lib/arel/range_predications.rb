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
    def strictly_left_of(value)
      Arel::Nodes::StrictlyLeftOf.new(self, Arel::Nodes.build_quoted(value, self))
    end

    # >>
    def strictly_right_of(value)
      Arel::Nodes::StrictlyRightOf.new(self, Arel::Nodes.build_quoted(value, self))
    end

    # &<
    def not_extend_right_of(value)
      Arel::Nodes::NotExtendRightOf.new(self, Arel::Nodes.build_quoted(value, self))
    end

    # &>
    def not_extend_left_of(value)
      Arel::Nodes::NotExtendLeftOf.new(self, Arel::Nodes.build_quoted(value, self))
    end

    # -|-
    def adjacent_to(value)
      Arel::Nodes::AdjacentTo.new(self, Arel::Nodes.build_quoted(value, self))
    end

  end
end
