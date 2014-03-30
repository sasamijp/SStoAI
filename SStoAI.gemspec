# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'SStoAI/version'

Gem::Specification.new do |spec|
  spec.name          = "SStoAI"
  spec.version       = SStoAI::VERSION
  spec.authors       = ["sasamijp"]
  spec.email         = ["k.seiya28@gmail.com"]
  spec.description   = %q{AI Creation tool}
  spec.summary       = %q{Create the AI that studies from 2ch short story .}
  spec.homepage      = "sasamijp.github.io"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency 'thor'
  spec.add_dependency 'twitter'
  spec.add_dependency 'tweetstream'
  spec.add_dependency 'natto'
  spec.add_dependency 'nokogiri'


end
