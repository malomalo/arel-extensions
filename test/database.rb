task = ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new({
  'adapter' => 'postgresql',
  'database' => "arel-extensions-test"
})
task.drop
task.create

ActiveRecord::Base.establish_connection({
  adapter:  "postgresql",
  database: "arel-extensions-test",
  encoding: "utf8"
})

ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Schema.define do

    create_table "addresses", force: :cascade do |t|
      t.integer  "name"
      t.integer  "property_id"
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