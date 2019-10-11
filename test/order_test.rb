require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  test '::order(column.asc)' do
    assert_sql(<<~SQL, Property.order(Property.arel_table[:id].asc))
      SELECT "properties".* FROM "properties" ORDER BY "properties"."id" ASC
    SQL
  end

  test '::order(column1.asc, column2.asc)' do
    assert_sql(<<~SQL, Property.order(Property.arel_table[:id].asc, Property.arel_table[:name].asc))
      SELECT "properties".* FROM "properties" ORDER BY "properties"."id" ASC, "properties"."name" ASC
    SQL
  end

  test '::order(column.desc)' do
    assert_sql(<<~SQL, Property.order(Property.arel_table[:id].desc))
      SELECT "properties".* FROM "properties" ORDER BY "properties"."id" DESC
    SQL
  end

  test '::order(column.asc(:nulls_first))' do
    assert_sql(<<~SQL, Property.order(Property.arel_table[:id].asc(:nulls_first)))
      SELECT "properties".* FROM "properties" ORDER BY "properties"."id" ASC NULLS FIRST
    SQL
  end
  
  test '::order(column.asc(:nulls_last))' do
    assert_sql(<<~SQL, Property.order(Property.arel_table[:id].asc(:nulls_last)))
      SELECT "properties".* FROM "properties" ORDER BY "properties"."id" ASC NULLS LAST
    SQL
  end

  test '::order(column.desc(:nulls_first))' do
    assert_sql(<<~SQL, Property.order(Property.arel_table[:id].desc(:nulls_first)))
      SELECT "properties".* FROM "properties" ORDER BY "properties"."id" DESC NULLS FIRST
    SQL
  end
  
  test '::order(column.desc(:nulls_last))' do
    assert_sql(<<~SQL, Property.order(Property.arel_table[:id].desc(:nulls_last)))
      SELECT "properties".* FROM "properties" ORDER BY "properties"."id" DESC NULLS LAST
    SQL
  end

end