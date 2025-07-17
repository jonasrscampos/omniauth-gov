# -*- encoding: utf-8 -*-
require File.expand_path('../lib/omniauth-gov/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jonas Ricardo", "Renato de Souza"]
  gem.email         = ["jonas.campos@yahoo.com.br", "renatocdesouza@gmail.com"]
  gem.description   = %q{Official OmniAuth strategy for GitHub.}
  gem.summary       = %q{Official OmniAuth strategy for GitHub.}
  gem.homepage      = "https://github.com/jonasrscampos/omniauth-gov"
  gem.license       = "MIT"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "omniauth-gov"
  gem.require_paths = ["lib"]
  gem.version       = OmniAuth::Gov::VERSION

  gem.add_dependency 'omniauth', '~> 2.0'
  gem.add_dependency 'omniauth-oauth2'
  gem.add_development_dependency 'rspec', '~> 3.5'
  gem.add_development_dependency 'faraday', '~> 2.9'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'webmock'
end
