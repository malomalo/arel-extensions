require 'test_helper'

# PostgreSQL's positional range operators. Each is an InfixOperation, so Arel's
# own visitor renders them and none needs a visitor here.
class RangePositionTest < ActiveSupport::TestCase

  EARLY = Time.utc(2026, 1, 1)...Time.utc(2026, 6, 30)
  LATE  = Time.utc(2026, 7, 1)...Time.utc(2026, 12, 31)

  def period
    Property.arel_table['period']
  end

  test 'strictly_left_of renders <<' do
    assert_sql(<<~SQL, period.strictly_left_of(LATE))
      "properties"."period" << '[2026-07-01 00:00:00,2026-12-31 00:00:00)'
    SQL
  end

  test 'strictly_right_of renders >>' do
    assert_sql(<<~SQL, period.strictly_right_of(EARLY))
      "properties"."period" >> '[2026-01-01 00:00:00,2026-06-30 00:00:00)'
    SQL
  end

  test 'not_extend_right_of renders &<' do
    assert_sql(<<~SQL, period.not_extend_right_of(LATE))
      "properties"."period" &< '[2026-07-01 00:00:00,2026-12-31 00:00:00)'
    SQL
  end

  test 'not_extend_left_of renders &>' do
    assert_sql(<<~SQL, period.not_extend_left_of(EARLY))
      "properties"."period" &> '[2026-01-01 00:00:00,2026-06-30 00:00:00)'
    SQL
  end

  test 'adjacent_to renders -|-' do
    assert_sql(<<~SQL, period.adjacent_to(LATE))
      "properties"."period" -|- '[2026-07-01 00:00:00,2026-12-31 00:00:00)'
    SQL
  end

  test 'every operator executes against PostgreSQL' do
    %i[strictly_left_of strictly_right_of not_extend_right_of not_extend_left_of adjacent_to].each do |op|
      Property.where(period.public_send(op, LATE)).first
    end
  end

  test 'an already-built node passes through untouched' do
    casted = Arel::Nodes::Casted.new(EARLY, period)

    assert_same casted, period.adjacent_to(casted).right
  end

  # The semantics, checked against PostgreSQL rather than asserted from the docs.
  test 'the operators mean what their names say' do
    connection = ActiveRecord::Base.lease_connection
    a = "int4range(1,5)"
    b = "int4range(5,10)"

    assert_equal true,  connection.select_value("SELECT #{a} << #{b}"),  '[1,5) is strictly left of [5,10)'
    assert_equal false, connection.select_value("SELECT #{a} >> #{b}"),  '[1,5) is not strictly right of [5,10)'
    assert_equal true,  connection.select_value("SELECT #{a} &< #{b}"),  '[1,5) does not extend right of [5,10)'
    assert_equal false, connection.select_value("SELECT #{a} &> #{b}"),  '[1,5) does extend left of [5,10)'
    assert_equal true,  connection.select_value("SELECT #{a} -|- #{b}"), '[1,5) abuts [5,10)'
  end

end
