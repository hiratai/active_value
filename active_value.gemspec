# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_value/version'

Gem::Specification.new do |spec|
  spec.name          = "active_value"
  spec.version       = ActiveValue::VERSION
  spec.authors       = ["Taiki Hiramatsu"]
  spec.email         = ["info@hiramatsu-sa-office.jp"]

  spec.summary       = %q{ActiveValue is base class for immutable value object that has interfaces like ActiveRecord.}
  spec.description   = %q{In a class inherited this class, constant variables get the behavior like records of ActiveRecord.}
  spec.homepage      = "https://github.com/hiratai/active_value"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3"

  spec.add_development_dependency "bundler", "> 1.0.0"
  spec.add_development_dependency "rake", "> 10.0"
  spec.add_development_dependency "minitest", "~> 5.14"
  spec.add_development_dependency "appraisal"
  # For Version 1.1
  # spec.add_development_dependency "activerecord", ">= 4.0.0"
  # spec.add_development_dependency "sqlite3"

  spec.add_dependency "activesupport", ">= 4.0.0"
end
