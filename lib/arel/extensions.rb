require File.expand_path('../array_predications', __FILE__)
require File.expand_path('../nodes/overlaps', __FILE__)
require File.expand_path('../nodes/contains', __FILE__)
Arel::Attributes::Attribute.include(Arel::ArrayPredications)


require File.expand_path('../attributes/key', __FILE__)
require File.expand_path('../attributes/cast', __FILE__)
require File.expand_path('../nodes/has_any_key', __FILE__)
require File.expand_path('../nodes/has_key', __FILE__)
require File.expand_path('../nodes/has_keys', __FILE__)
require File.expand_path('../json_predications', __FILE__)
Arel::Attributes::Attribute.include(Arel::JSONPredications)

if defined?(Arel::Visitors::PostgreSQL)
  require File.expand_path('../visitors/postgresql_extensions', __FILE__)
end