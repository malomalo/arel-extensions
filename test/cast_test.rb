require 'test_helper'

class CastTest < ActiveSupport::TestCase

  def metadata
    Property.arel_table['metadata']
  end
  
  test 'cast_as' do
    assert_sql(<<~SQL, metadata.dig('age').cast_as('integer'))
      ("properties"."metadata" #> array['age'])::integer
    SQL
  end

  test 'cast_as accepts qualified, modified and array types' do
    [
      'text',
      'varchar(255)',
      'numeric(10,2)',
      'timestamp with time zone',
      'int[]',
      'public.geometry'
    ].each do |type|
      assert_sql("(\"properties\".\"metadata\")::#{type}", metadata.cast_as(type))
    end
  end

  test 'cast_as rejects a type name that is not an identifier' do
    ['integer; DROP TABLE properties', "text' OR 1=1 --", 'int)) OR 1=1 --'].each do |type|
      assert_raises(ArgumentError) do
        ActiveRecord::Base.lease_connection.visitor.compile(metadata.cast_as(type))
      end
    end
  end

end
