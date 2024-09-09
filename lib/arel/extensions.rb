require "arel"
require File.expand_path('../nodes/binary_value', __FILE__)
require File.expand_path('../nodes/hex_encoded_binary_value', __FILE__)

require_relative "./nodes/geometry"
require_relative "./nodes/intersects"
require_relative "./nodes/within"
require_relative "./nodes/excludes"
require_relative "./nodes/contained_by"

require File.expand_path('../array_predications', __FILE__)
Arel::Attributes::Attribute.include(Arel::ArrayPredications)

require File.expand_path('../nodes/random', __FILE__)
require File.expand_path(File.join(__FILE__, '../../../ext/arel/nodes/ascending'))
require File.expand_path(File.join(__FILE__, '../../../ext/arel/nodes/descending'))
require File.expand_path(File.join(__FILE__, '../../../ext/arel/order_predications'))


require File.expand_path('../attributes/key', __FILE__)
require File.expand_path('../attributes/cast', __FILE__)
require File.expand_path('../nodes/has_any_key', __FILE__)
require File.expand_path('../nodes/has_key', __FILE__)
require File.expand_path('../nodes/has_keys', __FILE__)
require File.expand_path('../json_predications', __FILE__)
Arel::Attributes::Attribute.include(Arel::JSONPredications)

require File.expand_path('../nodes/ts_vector', __FILE__)
require File.expand_path('../nodes/ts_query', __FILE__)
require File.expand_path('../nodes/ts_match', __FILE__)
require File.expand_path('../nodes/ts_rank', __FILE__)
require File.expand_path('../nodes/ts_rank_cd', __FILE__)
require File.expand_path('../ts_predications', __FILE__)
Arel::Attributes::Attribute.include(Arel::TSPredications)

require File.expand_path('../nodes/relation', __FILE__)

require File.expand_path('../gis_predications', __FILE__)
Arel::Attributes::Attribute.include(Arel::GISPredications)

require File.expand_path('../../active_record/query_methods', __FILE__)

if defined?(Arel::Visitors::PostgreSQL)
  require File.expand_path('../visitors/postgresql_extensions', __FILE__)
end

if defined?(Arel::Visitors::Sunstone)
  require File.expand_path('../visitors/sunstone_extensions', __FILE__)
end

if defined?(Arel::Visitors::ToSql)
  require File.expand_path('../visitors/to_sql_extensions', __FILE__)
end
