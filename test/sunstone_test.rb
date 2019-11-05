require 'test_helper'

class SunstoneTest < ActiveSupport::TestCase

  # schema do
  #   create_table "properties", force: :cascade do |t|
  #     t.jsonb     'metadata'
  #   end
  # end

  # class Property < ActiveRecord::Base
  # end

  # test "::filter json_column: STRING throws an error" do
  #   assert_raises(ActiveRecord::UnkownFilterError) do
  #     Property.filter(metadata: 'string').load
  #   end
  # end
  
  # test "::filter json_column: {eq: JSON_HASH}" do
  #   query = Property.where(metadata: {eq: {json: 'string'}})
  #   assert_equal(<<-SQL.strip.gsub(/\s+/, ' '), query.to_sql.strip)
  #     SELECT "properties".*
  #     FROM "properties"
  #     WHERE "properties"."metadata" = '{\"json\":\"string\"}'
  #   SQL
  # end
  
  test "::filter json_column: {contains: JSON_HASH}" do
    query = SunstoneProperty.where(SunstoneProperty.arel_attribute('metadata').contains({json: 'string'}))
    assert_sar(query, 'GET', '/sunstone_properties', {
      where: {metadata: {contains: { json: 'string' }}}
    })
    
    # query = Property.where(metadata: {contains: {json: 'string'}})
    # assert_equal(<<-SQL.strip.gsub(/\s+/, ' '), query.to_sql.strip)
    #   SELECT "properties".*
    #   FROM "properties"
    #   WHERE "properties"."metadata" @> '{\"json\":\"string\"}'
    # SQL
  end

  # test "::filter json_column: {contained_by: JSON_HASH}" do
  #   query = Property.filter(metadata: {contained_by: {json: 'string'}})
  #   assert_equal(<<-SQL.strip.gsub(/\s+/, ' '), query.to_sql.strip)
  #     SELECT "properties".*
  #     FROM "properties"
  #     WHERE "properties"."metadata" <@ '{\"json\":\"string\"}'
  #   SQL
  # end
  
  # test "::filter json_column: {has_key: STRING}" do
  #   query = Property.filter(metadata: {has_key: 'string'})
  #   assert_equal(<<-SQL.strip.gsub(/\s+/, ' '), query.to_sql.strip)
  #     SELECT "properties".*
  #     FROM "properties"
  #     WHERE "properties"."metadata" ? 'string'
  #   SQL
  # end
  
  # test "::filter json_column.subkey: {eq: JSON_HASH}" do
  #   query = Property.filter("metadata.subkey" => {eq: 'string'})
  #   assert_equal(<<-SQL.strip.gsub(/\s+/, ' '), query.to_sql.strip)
  #     SELECT "properties".*
  #     FROM "properties"
  #     WHERE "properties"."metadata"#>'{subkey}' = 'string'
  #   SQL
  # end
  
  # test "::filter json_column: BOOLEAN" do
  #   query = Property.filter(metadata: true)
  #   assert_equal(<<-SQL.strip.gsub(/\s+/, ' '), query.to_sql.strip)
  #     SELECT "properties".*
  #     FROM "properties"
  #     WHERE "properties"."metadata" IS NOT NULL
  #   SQL
    
  #   query = Property.filter(metadata: "true")
  #   assert_equal(<<-SQL.strip.gsub(/\s+/, ' '), query.to_sql.strip)
  #     SELECT "properties".*
  #     FROM "properties"
  #     WHERE "properties"."metadata" IS NOT NULL
  #   SQL
    
  #   query = Property.filter(metadata: false)
  #   assert_equal(<<-SQL.strip.gsub(/\s+/, ' '), query.to_sql.strip)
  #     SELECT "properties".*
  #     FROM "properties"
  #     WHERE "properties"."metadata" IS NULL
  #   SQL
    
  #   query = Property.filter(metadata: "false")
  #   assert_equal(<<-SQL.strip.gsub(/\s+/, ' '), query.to_sql.strip)
  #     SELECT "properties".*
  #     FROM "properties"
  #     WHERE "properties"."metadata" IS NULL
  #   SQL
  # end

  test '::order(column.asc)' do
    query = SunstoneProperty.order(SunstoneProperty.arel_table[:id].asc)
    assert_sar(query, 'GET', '/sunstone_properties', {
      order: [{ id: :asc }]
    })
  end

  test '::order(column1.asc, column2.asc)' do
    query = SunstoneProperty.order(SunstoneProperty.arel_table[:id].asc, SunstoneProperty.arel_table[:name].asc)
    assert_sar(query, 'GET', '/sunstone_properties', {
      order: [{ id: :asc }, { name: :asc }]
    })
  end

  test '::order(column.desc)' do
    query = SunstoneProperty.order(SunstoneProperty.arel_table[:id].desc)
    assert_sar(query, 'GET', '/sunstone_properties', {
      order: [{ id: :desc }]
    })
  end

  test '::order(column.asc(:nulls_first))' do
    query = SunstoneProperty.order(SunstoneProperty.arel_table[:id].asc(:nulls_first))
    assert_sar(query, 'GET', '/sunstone_properties', {
      order: [{ id: { asc: :nulls_first } }]
    })
  end
  
  test '::order(column.asc(:nulls_last))' do
    query = SunstoneProperty.order(SunstoneProperty.arel_table[:id].asc(:nulls_last))
    assert_sar(query, 'GET', '/sunstone_properties', {
      order: [{ id: { asc: :nulls_last } }]
    })
  end

  test '::order(column.desc(:nulls_first))' do
    query = SunstoneProperty.order(SunstoneProperty.arel_table[:id].desc(:nulls_first))
    assert_sar(query, 'GET', '/sunstone_properties', {
      order: [{ id: { desc: :nulls_first } }]
    })
  end
  
  test '::order(column.desc(:nulls_last))' do
    query = SunstoneProperty.order(SunstoneProperty.arel_table[:id].desc(:nulls_last))
    assert_sar(query, 'GET', '/sunstone_properties', {
      order: [{ id: { desc: :nulls_last } }]
    })
  end

end
