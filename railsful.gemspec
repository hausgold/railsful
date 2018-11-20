lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'railsful/version'

Gem::Specification.new do |spec|
  spec.name          = 'railsful'
  spec.version       = Railsful::VERSION
  spec.authors       = ['Henning Vogt']
  spec.email         = ['git@henvo.de']

  spec.summary       = 'JSON API serializer and deserializer for Rails'
  spec.description   = 'This gem provides useful helper functions to interact' \
                       'with JSON API.'
  spec.homepage      = 'https://github.com/hausgold/restful'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  spec.add_dependency 'deep_merge', '~> 1'
  spec.add_dependency 'rails', ['>=4', '< 6']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.15'
end
