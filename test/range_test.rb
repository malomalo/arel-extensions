require 'test_helper'

# Range columns are typed by ActiveRecord as OID::Range, so a plain Ruby Range
# serializes to a PostgreSQL range literal through the attribute. These pin that
# down for each of the three range predicates — `contained_by` could not take a
# Range at all before, because it is the one that does not quote its operand.
class RangeTest < ActiveSupport::TestCase

  T1 = Time.utc(2026, 1, 1)
  T2 = Time.utc(2026, 12, 31)

  test 'contains a range' do
    query = Property.arel_table['period'].contains(T1...T2)

    assert_equal(
      %{"properties"."period" @> '[2026-01-01 00:00:00,2026-12-31 00:00:00)'},
      query.to_sql
    )
    Property.where(query).first
  end

  test 'overlaps a range' do
    query = Property.arel_table['period'].overlaps(T1...Time.utc(2026, 6, 30))

    assert_equal(
      %{"properties"."period" && '[2026-01-01 00:00:00,2026-06-30 00:00:00)'},
      query.to_sql
    )
    Property.where(query).first
  end

  test 'contained by a range' do
    query = Property.arel_table['period'].contained_by(Time.utc(2000, 1, 1)...Time.utc(2030, 1, 1))

    assert_equal(
      %{"properties"."period" <@ '[2000-01-01 00:00:00,2030-01-01 00:00:00)'},
      query.to_sql
    )
    Property.where(query).first
  end

  test 'an inclusive end is distinct from an exclusive one' do
    attribute = Property.arel_table['period']

    assert_equal(
      %{"properties"."period" @> '[2026-01-01 00:00:00,2026-12-31 00:00:00]'},
      attribute.contains(T1..T2).to_sql
    )
    assert_equal(
      %{"properties"."period" @> '[2026-01-01 00:00:00,2026-12-31 00:00:00)'},
      attribute.contains(T1...T2).to_sql
    )
  end

  test 'unbounded ends' do
    attribute = Property.arel_table['period']

    assert_equal(
      %{"properties"."period" @> '[2026-01-01 00:00:00,infinity]'},
      attribute.contains(T1..nil).to_sql
    )
    assert_equal(
      %{"properties"."period" @> '[,2026-12-31 00:00:00]'},
      attribute.contains(nil..T2).to_sql
    )
  end

  test 'a daterange column' do
    query = Property.arel_table['season'].contained_by(Date.new(2026, 1, 1)..Date.new(2026, 12, 31))

    assert_equal(
      %{"properties"."season" <@ '[2026-01-01,2026-12-31]'},
      query.to_sql
    )
    Property.where(query).first
  end

  # The Range branch must not disturb what JSON and ARRAY callers pass, which
  # they quote themselves.
  test 'contained_by leaves a non-Range operand untouched' do
    attribute = Property.arel_table['metadata']
    casted = Arel::Nodes::Casted.new({a: 1}.to_json, attribute)

    assert_same casted, attribute.contained_by(casted).right
  end

end
