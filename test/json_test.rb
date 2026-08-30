require 'test_helper'

class JSONTest < ActiveSupport::TestCase

  test 'dig renders a jsonb path' do
    query = Property.arel_table['metadata'].dig('key').eq('v')

    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      "properties"."metadata"#>'{"key"}' = 'v'
    SQL
  end

  test 'dig renders a nested jsonb path' do
    query = Property.arel_table['metadata'].dig('a', 'b').eq('v')

    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      "properties"."metadata"#>'{"a","b"}' = 'v'
    SQL
  end

  test 'dig escapes a path key so it cannot break out of the literal' do
    query = Property.arel_table['metadata'].dig("key}' OR 1=1 --").eq('v')
    sql = query.to_sql

    # the quote is doubled and the whole key is kept inside one array element
    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, sql)
      "properties"."metadata"#>'{"key}'' OR 1=1 --"}' = 'v'
    SQL

    # the injected boolean must not sit outside the path literal as live SQL
    refute_includes sql, "}' OR 1=1"
  end

end
