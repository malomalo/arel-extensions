require 'test_helper'

class JSONTest < ActiveSupport::TestCase

  def metadata
    Property.arel_table['metadata']
  end
  
  test '#key' do
    assert_sql(<<~SQL, Property.where(metadata.key('name').eq('bob')))
      SELECT "properties".* FROM "properties"
      WHERE "properties"."metadata" #> array['name'] = 'bob'
    SQL
  end

  test '#key aliases' do
    assert_sql(<<~SQL, metadata['name'])
      "properties"."metadata" #> array['name']
    SQL

    assert_sql(<<~SQL, metadata.index('name'))
      "properties"."metadata" #> array['name']
    SQL
  end

  test '#dig' do
    query = Property.where(metadata.dig('address', 'zip').eq('12345'))

    assert_sql(<<~SQL,  query)
      SELECT "properties".* FROM "properties"
      WHERE "properties"."metadata" #> array['address','zip'] = '12345'
    SQL
  end

  test '#dig with symbol keys' do
    assert_sql(<<~SQL, metadata.dig(:address, :zip))
      "properties"."metadata" #> array['address','zip']
    SQL
  end

  test '#dig with an array of keys' do
    assert_sql(<<~SQL, metadata.dig(['a', 'b']))
      "properties"."metadata" #> array['a','b']
    SQL
  end

  test '#dig with an array of symbols' do
    assert_sql(<<~SQL, metadata.dig([:a, :b]))
      "properties"."metadata" #> array['a','b']
    SQL
  end

  test '#dig with no keys returns the attribute' do
    assert_sql(<<~SQL, metadata.dig)
      "properties"."metadata"
    SQL
  end

  test '#key quotes segments containing quotes and backslashes' do
    query = metadata.dig(%q{o'brien}, %q{e"f}, %q{g\\h})
    
    assert_sql(<<~SQL, query)
      "properties"."metadata" #> array['o''brien','e"f','g\\h']
    SQL

    # ...and Postgres reads the segments back out unchanged
    Property.create!(name: 'odd',   metadata: { %q{o'brien} => { 'e"f' => { 'g\\h' => 'found' } } })
    Property.create!(name: 'plain', metadata: { 'a' => 'b' })
    assert_equal ['odd'], Property.where(query.not_eq(nil)).pluck(:name)
  end

  # GHSA-75hc-9q9v-9cv2: a `}'` in a path segment used to close the `#>'{...}'`
  # literal, so everything after it was treated as SQL.
  test 'a path segment cannot break out of the json path' do
    Property.create!(name: 'public', metadata: { 'key' => 'v' })
    Property.create!(name: 'secret', metadata: { 'other' => 'z' })
    
    %w(} ]).each do |delemitier|
      payload = "key'#{delemitier} IS NOT NULL OR 1=1 --"
      query   = Property.where(metadata.dig(payload).not_eq(nil))
  
      assert_sql(<<~SQL, query)
        SELECT "properties".* FROM "properties"
        WHERE "properties"."metadata" #> array['key''#{delemitier} IS NOT NULL OR 1=1 --'] IS NOT NULL
      SQL
  
      # No row has the (nonsense) key, so nothing may come back. Before the fix
      # the injected `OR 1=1` returned every row.
      assert_equal [], query.pluck(:name)
    end
  end

  test 'has_key' do
    assert_sql(%q("properties"."metadata" ? 'name'), metadata.has_key('name'))
  end

  test 'has_keys' do
    assert_sql(<<~SQL, metadata.has_keys('a', 'b'))
      "properties"."metadata" ?& array['a','b']
    SQL
  end

  test 'has_any_key' do
    assert_sql(<<~SQL, metadata.has_any_key('a', 'b'))
      "properties"."metadata" ?| array['a','b']
    SQL
  end

end
