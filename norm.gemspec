# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'norm/version'

Gem::Specification.new do |spec|
  spec.name          = 'norm'
  spec.version       = Norm::VERSION
  spec.authors       = ['Ernie Miller']
  spec.email         = ['ernie@ernie.io']
  spec.summary       = %q{Pithy short summary.}
  spec.description   = %q{Summary with room for extra pith.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'terminal-notifier-guard'
  spec.add_development_dependency 'activemodel', '~> 7.0'

  spec.add_dependency 'pg'
  spec.add_dependency 'connection_pool'
end
