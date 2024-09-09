require 'test_helper'

class BinaryValueTest < ActiveSupport::TestCase

  test 'binary value' do
    query = Property.where( Arel::Nodes::BinaryValue.new("\x01\x01\x00\x00\x00\xC0K\x9B\x84\xD0.<@\b\x96\xA2n\x84%&@") )

    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      SELECT "properties".* FROM "properties"
      WHERE '\\x0101000000c04b9b84d02e3c400896a26e84252640'
    SQL
  end

  test 'hex encoded binary value' do
    query = Property.where( Arel::Nodes::HexEncodedBinaryValue.new("0101000000c04b9b84d02e3c400896a26e84252640") )

    assert_equal(<<~SQL.gsub(/( +|\n)/, ' ').strip, query.to_sql)
      SELECT "properties".* FROM "properties"
      WHERE '\\x0101000000c04b9b84d02e3c400896a26e84252640'
    SQL
  end

end
