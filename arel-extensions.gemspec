require File.expand_path("../lib/arel/extensions/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name = 'arel-extensions'
  gem.version       = Arel::Extensions::VERSION
  gem.authors       = ["Jon Bracy"]
  gem.email         = ["jonbracy@gmail.com"]
  gem.summary       = %q{Adds support for missing SQL operators and functions to Arel}
  gem.homepage      = 'https://github.com/malomalo/arel-extensions'
  gem.licenses      = ['MIT']

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]

  gem.add_dependency 'activerecord', '>= 7.0.0'

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "byebug"
  gem.add_development_dependency "rake"
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'minitest-reporters'
  gem.add_development_dependency "sunstone", '>= 7.0.0'
  gem.add_development_dependency "webmock"
  gem.add_development_dependency 'pg'
  gem.add_development_dependency 'rgeo'

end
