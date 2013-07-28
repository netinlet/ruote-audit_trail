# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'audit_trail/version'

Gem::Specification.new do |spec|
  spec.name          = "ruote-audit_trail"
  spec.version       = Ruote::AuditTrail::VERSION
  spec.authors       = ["Danny Northox", "Doug Bryant"]
  spec.email         = ["danny@mantor.org", "doug@netinlet.com"]
  spec.description   = %q{TODO: Write a gem description}
  spec.summary       = %q{TODO: Write a gem summary}
  spec.homepage      = "https://github.com/northox/ruote-audit_trail"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rack-test'

  spec.add_runtime_dependency 'sinatra'
  spec.add_runtime_dependency 'sinatra-contrib'
  spec.add_runtime_dependency 'sinatra-respond_to'
  spec.add_runtime_dependency 'ruote'
  spec.add_runtime_dependency 'ruote-sequel'
end
