require_relative "lib/arel/extensions/version"

Gem::Specification.new do |gem|
  gem.name          = 'arel-extensions'
  gem.version       = Arel::Extensions::VERSION
  gem.authors       = ["Jon Bracy"]
  gem.email         = ["jonbracy@gmail.com"]
  gem.summary       = %q{Adds support for missing SQL operators and functions to Arel}
  gem.description   = %q{Extends Arel and ActiveRecord with SQL operators and functions that aren't available out of the box, including array and JSON predicates, PostgreSQL full-text search (tsvector/tsquery), GIS/geometry predicates, and additional ordering helpers.}
  gem.homepage      = 'https://github.com/malomalo/arel-extensions'
  gem.licenses      = ['MIT']

  gem.metadata = {
    "source_code_uri"       => gem.homepage,
    "changelog_uri"         => "#{gem.homepage}/blob/master/CHANGELOG.md",
    "rubygems_mfa_required" => "true",
  }

  gem.required_ruby_version = '>= 3.3'

  gem.files         = `git ls-files -- lib ext CHANGELOG.md LICENSE README.md`.split("\n")
  gem.require_paths = ["lib"]

  gem.add_dependency 'activerecord', '>= 8.0.0', '< 9.0'

  gem.add_development_dependency "debug"
  gem.add_development_dependency "rake"
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'minitest-reporters'
  gem.add_development_dependency "sunstone", '>= 7.0.0'
  gem.add_development_dependency "webmock"
  gem.add_development_dependency 'pg'
  gem.add_development_dependency 'rgeo'
  gem.add_development_dependency "activerecord-postgis-adapter", '>= 8.0'

end
