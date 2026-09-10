require 'test_helper'

# `not_overlaps` is the negation of Arel core's `overlaps`. PostgreSQL has no
# `!&&` operator, so it renders as `NOT (left && right)` — the same shape as
# `excludes`, which negates `@>`.
class NotOverlapsTest < ActiveSupport::TestCase

  test 'negates overlaps on an array column' do
    query = Property.arel_table['tags'].not_overlaps(['a', 'b'])

    assert_sql(<<~SQL, query)
      NOT ("properties"."tags" && '{a,b}')
    SQL

    Property.where(query).first
  end

  test 'negates overlaps on a range column' do
    query = Property.arel_table['period'].not_overlaps(Time.utc(2026, 1, 1)...Time.utc(2026, 12, 31))

    assert_sql(<<~SQL, query)
      NOT ("properties"."period" && '[2026-01-01 00:00:00,2026-12-31 00:00:00)')
    SQL

    Property.where(query).first
  end

  test 'an already-built node passes through untouched' do
    casted = Arel::Nodes::Casted.new(['a'], Property.arel_table['tags'])

    assert_same casted, Property.arel_table['tags'].not_overlaps(casted).right
  end

  test 'it is the negation of overlaps' do
    attribute = Property.arel_table['period']
    range = Time.utc(2026, 1, 1)...Time.utc(2026, 12, 31)

    assert_sql("NOT (#{attribute.overlaps(range).to_sql})", attribute.not_overlaps(range))
  end

end
