require 'test_helper'

class TSTest < ActiveSupport::TestCase

  test 'tsquery(query)' do
    query = Property.where( Arel::Nodes::TSQuery.new('query') )

    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      SELECT "properties".* FROM "properties"
      WHERE to_tsquery('query')
    SQL
  end
  
  test 'tsquery(query, language: lang)' do
    query = Property.where( Arel::Nodes::TSQuery.new('query', language: 'lang') )

    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      SELECT "properties".* FROM "properties"
      WHERE to_tsquery('lang', 'query')
    SQL
  end
  
  test 'tsvector(attribute)' do
    query = Property.where( Arel::Nodes::TSVector.new(Property.arel_table[:name]) )

    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      SELECT "properties".* FROM "properties"
      WHERE to_tsvector("properties"."name")
    SQL
  end
  
  test 'tsvector(text)' do
    query = Property.where( Arel::Nodes::TSVector.new(
      Arel::Nodes::Quoted.new("my data O'Malley")
    ))

    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      SELECT "properties".* FROM "properties"
      WHERE to_tsvector('my data O''Malley')
    SQL
  end

  test 'tsvector(attribute, language: lang)' do
    query = Property.where( Arel::Nodes::TSVector.new(Property.arel_table[:name], language: 'lang') )

    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      SELECT "properties".* FROM "properties"
      WHERE to_tsvector('lang', "properties"."name")
    SQL
  end

  test 'ts_match(attrbute, tsquery)' do
    query = Property.where(
      Arel::Nodes::TSMatch.new(
        Property.arel_table[:name],
        Arel::Nodes::TSQuery.new('query')
      )
    )

    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      SELECT "properties".* FROM "properties"
      WHERE "properties"."name" @@ to_tsquery('query')
    SQL
  end

  test 'ts_match(tsvector, tsquery)' do
    query = Property.where(
      Arel::Nodes::TSMatch.new(
        Arel::Nodes::TSVector.new(Property.arel_table[:name]),
        Arel::Nodes::TSQuery.new('query')
      )
    )

    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      SELECT "properties".* FROM "properties"
      WHERE to_tsvector("properties"."name") @@ to_tsquery('query')
    SQL
  end

  test 'ts_rank(attribute, tsquery)' do
    query = Property.where(
      Arel::Nodes::TSRank.new(
        Property.arel_table[:name],
        Arel::Nodes::TSQuery.new('query')
      )
    )
    
    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      SELECT "properties".* FROM "properties"
      WHERE ts_rank("properties"."name", to_tsquery('query'))
    SQL
  end
    
  test 'ts_rank(tsvector, tsquery)' do
    query = Property.where(
      Arel::Nodes::TSRank.new(
        Arel::Nodes::TSVector.new(Property.arel_table[:name]),
        Arel::Nodes::TSQuery.new('query')
      )
    )
    
    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      SELECT "properties".* FROM "properties"
      WHERE ts_rank(to_tsvector("properties"."name"), to_tsquery('query'))
    SQL
  end

  test 'ts_rank_cd(attribute, tsquery)' do
    query = Property.where(
      Arel::Nodes::TSRankCD.new(
        Property.arel_table[:name],
        Arel::Nodes::TSQuery.new('query')
      )
    )
    
    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      SELECT "properties".* FROM "properties"
      WHERE ts_rank_cd("properties"."name", to_tsquery('query'))
    SQL
  end
    
  test 'ts_rank_cd(tsvector, tsquery)' do
    query = Property.where(
      Arel::Nodes::TSRankCD.new(
        Arel::Nodes::TSVector.new(Property.arel_table[:name]),
        Arel::Nodes::TSQuery.new('query')
      )
    )
    
    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      SELECT "properties".* FROM "properties"
      WHERE ts_rank_cd(to_tsvector("properties"."name"), to_tsquery('query'))
    SQL
  end

  test 'ts_rank_cd(tsvector, tsquery, normalization)' do
    query = Property.where(
      Arel::Nodes::TSRankCD.new(
        Arel::Nodes::TSVector.new(Property.arel_table[:name]),
        Arel::Nodes::TSQuery.new('query'),
        5
      )
    )
    
    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      SELECT "properties".* FROM "properties"
      WHERE ts_rank_cd(to_tsvector("properties"."name"), to_tsquery('query'), 5)
    SQL
  end

end
