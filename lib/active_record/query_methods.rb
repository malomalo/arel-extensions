# frozen_string_literal: true

require 'active_record'
require 'active_record/relation'
require 'active_record/querying'
require 'active_record/relation/query_methods'

module ActiveRecord
  # Prepended onto ActiveRecord::QueryMethods rather than reopening it, so
  # these methods don't appear in QueryMethods.public_instance_methods(false)
  # -- which Rails' QueryingMethodsDelegationTest asserts against -- while
  # relations still respond to them.
  module DistinctOn
    def distinct_on_values
      @values["distinct_on_values"] || []
    end

    def distinct_on_values=(value)
      @values["distinct_on_values"] = value
    end

    def distinct_on(*fields)
      spawn.distinct_on!(*fields)
    end
    alias uniq_on distinct_on

    def distinct_on!(*fields)
      fields.flatten!
      self.distinct_on_values = fields.map { |x| x.is_a?(Arel::Attributes::Attribute) ? x : klass.arel_table[x] }
      self
    end
    alias uniq_on! distinct_on!

    private

    # Version-agnostic: forward whatever build_arel receives (its signature
    # varies across Rails versions) to the original via super, then apply
    # the accumulated distinct_on values.
    def build_arel(*args)
      arel = super
      arel.distinct_on(self.distinct_on_values) if !self.distinct_on_values.empty?
      arel
    end
  end
end

ActiveRecord::QueryMethods.prepend(ActiveRecord::DistinctOn)
ActiveRecord::Querying.delegate :distinct_on, to: :all
ActiveRecord::Querying.delegate :uniq_on, to: :all
