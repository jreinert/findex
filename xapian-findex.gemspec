# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'findex/version'

Gem::Specification.new do |spec|
  spec.name          = 'xapian-findex'
  spec.version       = Findex::VERSION
  spec.authors       = ['Joakim Reinert']
  spec.email         = ['mail@jreinert.com']
  spec.license       = 'MIT'

  spec.summary       = 'A simple file indexer and full text search using Xapian'
  spec.description   = 'Findex indexes files in a path recursively, updates ' \
                       'existing ones and deletes removed files from the index'
  spec.homepage      = 'https://github.com/jreinert/findex'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f =~ %r{^(test|spec|features)/} }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'xapian', '~> 1.2'
  spec.add_dependency 'ruby-filemagic', '~> 0.7'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry-byebug', '~> 3.3'
  spec.add_development_dependency 'pry-doc', '~> 0.8'
end
