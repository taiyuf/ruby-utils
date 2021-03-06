# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'utils/version'

Gem::Specification.new do |spec|
  spec.name          = "utils"
  spec.version       = Utils::VERSION
  spec.authors       = ["Taiyu Fujii"]
  spec.email         = ["tf.900913@gmail.com"]
  spec.summary       = %q{Utilities module for ruby with rails.}
  spec.description   = %q{Utils::Configuration => simple management tool by yaml.}
  spec.homepage      = "https://github.com/taiyuf/ruby_utils"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "hashie"
  spec.add_development_dependency "rack"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "minitest"
end
