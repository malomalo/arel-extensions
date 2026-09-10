# frozen_string_literal: true

module Arel
  module Nodes
    # The negation of `&&`. PostgreSQL has no `!&&` operator, so this renders as
    # `NOT (left && right)` — the same shape as Excludes, which negates `@>`.
    class NotOverlaps < Binary
    end
  end
end
