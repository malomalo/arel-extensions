ActiveRecord::Base.establish_connection({
  adapter:  "postgis",
  database: "arel-extensions-test",
  encoding: "utf8"
})

db_config = ActiveRecord::Base.connection_db_config
task = ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new(db_config)
task.drop
task.create

ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Schema.define do
    enable_extension "postgis"

    create_table "addresses", force: :cascade do |t|
      t.integer  "name"
      t.integer  "property_id"
      t.geometry "location",             limit: {:type=>"Point", :srid=>"4326"}
    end

    create_table "properties", force: :cascade do |t|
      t.string   "name",                 limit: 255
      t.tsvector 'vector_col'
      t.jsonb     'metadata'
    end

  end
end

class Address < ActiveRecord::Base
  belongs_to :property
end

class Property < ActiveRecord::Base
  has_many :addresses
end

class SunstoneRecord < ActiveRecord::Base
  self.abstract_class = true
end

class SunstoneAddress < SunstoneRecord
  belongs_to :property, class_name: 'SunstoneProperty'
end

class SunstoneProperty < SunstoneRecord
  has_many :addresses, class_name: 'SunstoneAddress'
end

SunstoneRecord.establish_connection(adapter: 'sunstone', url: 'http://example.com')
