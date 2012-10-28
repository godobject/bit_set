# -*- encoding: utf-8 -*-
require File.expand_path('../lib/god_object/bit_set/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Alexander E. Fischer"]
  gem.email         = ["aef@raxys.net"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "bit_set"
  gem.require_paths = ["lib"]
  gem.version       = GodObject::BitSet::VERSION.dup

  gem.add_development_dependency('rspec', '2.11.0')
  gem.add_development_dependency('pry')
end
