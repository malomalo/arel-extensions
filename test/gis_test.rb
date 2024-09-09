require 'test_helper'

class GISTest < ActiveSupport::TestCase

  test 'intersects' do
    query = Address.arel_table['location'].intersects('POINT (28.182869232095754 11.073276002261096)')

    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      ST_Intersects("addresses"."location", '0101000000c04b9b84d02e3c400896a26e84252640')
    SQL
  end

  test 'within' do
    query = Address.arel_table['location'].within('POINT (28.182869232095754 11.073276002261096)')

    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      ST_Within("addresses"."location", '0101000000c04b9b84d02e3c400896a26e84252640')
    SQL

    result = Address.where(query).first
  end

end
