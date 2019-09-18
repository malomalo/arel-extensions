require "arel"
require File.expand_path('../nodes/hex_encoded_binary', __FILE__)

require File.expand_path('../nodes/overlaps', __FILE__)
require File.expand_path('../nodes/contains', __FILE__)
require File.expand_path('../nodes/within', __FILE__)
require File.expand_path('../nodes/excludes', __FILE__)
require File.expand_path('../nodes/contained_by', __FILE__)
require File.expand_path('../array_predications', __FILE__)
Arel::Attributes::Attribute.include(Arel::ArrayPredications)


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