require 'test_helper'

# PostgreSQL has no `!&&`, so a negated overlap is Arel's own `Not` wrapped
# around core's `overlaps` — `attribute.overlaps(x).not`. There is no dedicated
# predication for it; these pin that the core spelling renders and executes, and
# that the Sunstone visitor has something to serialize.
class NegationTest < ActiveSupport::TestCase

  test 'negating overlaps on an array column' do
    query = Property.arel_table['tags'].overlaps(['a', 'b']).not

    assert_sql(<<~SQL, query)
      NOT ("properties"."tags" && '{a,b}')
    SQL

    Property.where(query).first
  end

  test 'negating overlaps on a range column' do
    query = Property.arel_table['period'].overlaps(Time.utc(2026, 1, 1)...Time.utc(2026, 12, 31)).not

    assert_sql(<<~SQL, query)
      NOT ("properties"."period" && '[2026-01-01 00:00:00,2026-12-31 00:00:00)')
    SQL

    Property.where(query).first
  end

  test 'the operand is quoted by overlaps, so a built node passes through' do
    casted = Arel::Nodes::Casted.new(['a'], Property.arel_table['tags'])

    assert_same casted, Property.arel_table['tags'].overlaps(casted).not.expr.right
  end

  test 'it wraps the overlap rather than replacing it' do
    attribute = Property.arel_table['period']
    range = Time.utc(2026, 1, 1)...Time.utc(2026, 12, 31)

    assert_sql("NOT (#{attribute.overlaps(range).to_sql})", attribute.overlaps(range).not)
  end

end
