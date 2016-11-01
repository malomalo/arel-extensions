require 'active_record'
require 'active_record/relation'
require 'active_record/querying'
require 'active_record/relation/query_methods'

module ActiveRecord::QueryMethods
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

  def build_arel_with_distinct_on
    arel = build_arel_without_distinct_on
    arel.distinct_on(self.distinct_on_values) if !self.distinct_on_values.empty?
    arel
  end
  alias_method :build_arel_without_distinct_on, :build_arel
  alias_method :build_arel, :build_arel_with_distinct_on
end

ActiveRecord::Querying.delegate :distinct_on, to: :all
ActiveRecord::Querying.delegate :distinct_on!, to: :all