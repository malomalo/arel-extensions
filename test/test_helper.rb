# To make testing/debugging easier, test within this source tree versus an
# installed gem
$LOAD_PATH << File.expand_path('../lib', __FILE__)

# require 'simplecov'
# SimpleCov.start do
#   add_group 'lib', 'sunstone/lib'
#   add_group 'ext', 'sunstone/ext'
# end

require 'rgeo'
require "minitest/autorun"
require 'minitest/unit'
require 'minitest/reporters'
require 'webmock/minitest'
# require 'mocha/minitest'
require 'active_record'
require 'sunstone'
require 'arel/extensions'


# Setup the test db
ActiveSupport.test_order = :random
require File.expand_path('../database', __FILE__)

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

$debugging = false

# File 'lib/active_support/testing/declarative.rb', somewhere in rails....
class ActiveSupport::TestCase
  include WebMock::API
  
  # File 'lib/active_support/testing/declarative.rb'
  def self.test(name, &block)
    test_name = "test_#{name.gsub(/\s+/, '_')}".to_sym
    defined = method_defined? test_name
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
      define_method(test_name, &block)
    else
      define_method(test_name) do
        skip "No implementation provided for #{name}"
      end
    end
  end
  
  def webmock(method, path, query=nil)
    query = deep_transform_query(query) if query

    stub_request(method, /^#{ActiveRecord::Base.connection.instance_variable_get(:@connection).url}/).with do |req|
      if query
        req&.uri&.path == path && req.uri.query && unpack(req.uri.query.sub(/=true$/, '')) == query
      else
        req&.uri&.path == path && req.uri.query.nil?
      end
    end
  end
  
  def setup
    sunstone_schema = {
      addresses: {
        columns: {
          id: { type: :integer, primary_key: true, null: false, array: false },
          name: { type: :string, primary_key: false, null: true, array: false },
          property_id: { type: :integer, primary_key: false, null: true, array: false }
        }
      },
      properties: {
        columns: {
          id: { type: :integer, primary_key: true, null: false, array: false },
          name: { type: :string, primary_key: false, null: true, array: false },
          metadata: { type: :json, primary_key: false, null: true, array: false }
        }
      }
    }
    
    req_stub = stub_request(:get, /^http:\/\/example.com/).with do |req|
      case req.uri.path
      when '/tables'
        true
      when /^\/\w+\/schema$/i
        true
      else
        false
      end
    end
    
    req_stub.to_return do |req|
      case req.uri.path
      when '/tables'
        {
          body: sunstone_schema.keys.to_json,
          headers: { 'StandardAPI-Version' => '5.0.0.5' }
        }
      when /^\/(\w+)\/schema$/i
        {
          body: sunstone_schema[$1.to_sym].to_json,
          headers: { 'StandardAPI-Version' => '5.0.0.5' }
        }
      end
    end
  end

  def debug
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    $debugging = true
    yield
  ensure
    ActiveRecord::Base.logger = nil
    $debugging = false
  end


  class SQLLogger
    class << self
      attr_accessor :ignored_sql, :log, :log_all
      def clear_log; self.log = []; self.log_all = []; end
    end

    self.clear_log

    self.ignored_sql = [/^PRAGMA/i, /^SELECT currval/i, /^SELECT CAST/i, /^SELECT @@IDENTITY/i, /^SELECT @@ROWCOUNT/i, /^SAVEPOINT/i, /^ROLLBACK TO SAVEPOINT/i, /^RELEASE SAVEPOINT/i, /^SHOW max_identifier_length/i, /^BEGIN/i, /^COMMIT/i]

    # FIXME: this needs to be refactored so specific database can add their own
    # ignored SQL, or better yet, use a different notification for the queries
    # instead examining the SQL content.
    oracle_ignored     = [/^select .*nextval/i, /^SAVEPOINT/, /^ROLLBACK TO/, /^\s*select .* from all_triggers/im, /^\s*select .* from all_constraints/im, /^\s*select .* from all_tab_cols/im]
    mysql_ignored      = [/^SHOW FULL TABLES/i, /^SHOW FULL FIELDS/, /^SHOW CREATE TABLE /i, /^SHOW VARIABLES /, /^\s*SELECT (?:column_name|table_name)\b.*\bFROM information_schema\.(?:key_column_usage|tables)\b/im]
    postgresql_ignored = [/^\s*select\b.*\bfrom\b.*pg_namespace\b/im, /^\s*select tablename\b.*from pg_tables\b/im, /^\s*select\b.*\battname\b.*\bfrom\b.*\bpg_attribute\b/im, /^SHOW search_path/i]
    sqlite3_ignored =    [/^\s*SELECT name\b.*\bFROM sqlite_master/im, /^\s*SELECT sql\b.*\bFROM sqlite_master/im]

    [oracle_ignored, mysql_ignored, postgresql_ignored, sqlite3_ignored].each do |db_ignored_sql|
      ignored_sql.concat db_ignored_sql
    end

    attr_reader :ignore

    def initialize(ignore = Regexp.union(self.class.ignored_sql))
      @ignore = ignore
    end

    def call(name, start, finish, message_id, values)
      sql = values[:sql]

      # FIXME: this seems bad. we should probably have a better way to indicate
      # the query was cached
      return if 'CACHE' == values[:name]

      self.class.log_all << sql
      unless ignore =~ sql
        if $debugging
        puts caller.select { |l| l.starts_with?(File.expand_path('../../lib', __FILE__)) }
        puts "\n\n" 
        end
      end
      self.class.log << sql unless ignore =~ sql
    end
  end
  ActiveSupport::Notifications.subscribe('sql.active_record', SQLLogger.new)

  def deep_transform_query(object)
    case object
    when Hash
      object.each_with_object({}) do |(key, value), result|
        result[key.to_s] = deep_transform_query(value)
      end
    when Array
      object.map {|e| deep_transform_query(e) }
    when Symbol
      object.to_s
    else
      object
    end
  end
  
  def assert_sar(query, method, path, query_params = {}, body = nil)
    sar = query.to_sar

    assert_equal method, sar.method
    assert_equal path, sar.path.split('?').first
    assert_equal deep_transform_query(query_params), MessagePack.unpack(CGI::unescape(sar.path.split('?').last))
    if body.nil?
      assert_nil sar.body
    else
      assert_equal body, sar.body
    end
  end
  
  def assert_sql(expected, query)
    assert_equal expected.strip, query.to_sql.strip.gsub(/\s+/, ' ')
  end
  # test/unit backwards compatibility methods
  alias :assert_raise :assert_raises
  alias :assert_not_empty :refute_empty
  alias :assert_not_equal :refute_equal
  alias :assert_not_in_delta :refute_in_delta
  alias :assert_not_in_epsilon :refute_in_epsilon
  alias :assert_not_includes :refute_includes
  alias :assert_not_instance_of :refute_instance_of
  alias :assert_not_kind_of :refute_kind_of
  alias :assert_no_match :refute_match
  alias :assert_not_nil :refute_nil
  alias :assert_not_operator :refute_operator
  alias :assert_not_predicate :refute_predicate
  alias :assert_not_respond_to :refute_respond_to
  alias :assert_not_same :refute_same
  
end