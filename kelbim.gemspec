# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kelbim/version'

Gem::Specification.new do |spec|
  spec.name          = "kelbim"
  spec.version       = Kelbim::VERSION
  spec.authors       = ["winebarrel"]
  spec.email         = ["sgwr_dts@yahoo.co.jp"]
  spec.description   = "Kelbim is a tool to manage ELB. It defines the state of ELB using DSL, and updates ELB according to DSL."
  spec.summary       = "Kelbim is a tool to manage ELB."
  spec.homepage      = "http://kelbim.codenize.tools/"
  spec.license       = "MIT"

  #spec.files         = `git ls-files`.split($/)
  spec.files         = %w(README.md) + Dir.glob('bin/**/*') + Dir.glob('lib/**/*')
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  #spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk-v1", ">= 1.59.0"
  spec.add_dependency "uuid"
  spec.add_dependency "rspec"
  spec.add_dependency "json"
  spec.add_dependency "term-ansicolor"
  spec.add_dependency "diffy"
  spec.add_dependency "hashie"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec-instafail"
end
