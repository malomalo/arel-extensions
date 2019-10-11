# Ordering with :nulls_last, :nulls_first options
module Arel
  module OrderPredications

    def asc(nulls=nil)
      Nodes::Ascending.new self, nulls
    end

    def desc(nulls=nil)
      Nodes::Descending.new self, nulls
    end

  end
end