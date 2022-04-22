# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "logging_lint/gem_version"

Gem::Specification.new do |spec|
  spec.name          = "danger-logging_lint"
  spec.version       = LoggingLint::VERSION
  spec.authors       = ["David Sucharda"]
  spec.email         = ["david.sucharda@eman.cz"]
  spec.description   = "Checks logging commands in code."
  spec.summary       = "Since logging can be a security issue in some cases (ex: usage in production) this linter checks for logs with variables and triggers warning for them using Danger."
  spec.homepage      = "https://github.com/eManPrague/danger-logging_lint"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "danger-plugin-api", "~> 1.0"

  # General ruby development
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"

  # Testing support
  spec.add_development_dependency 'codecov', '~> 0.5.1'
  spec.add_development_dependency "rspec", "~> 3.4"

  # Linting code and docs
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "yard"

  # Makes testing easy via `bundle exec guard`
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"

  # If you want to work on older builds of ruby
  spec.add_development_dependency "listen", "3.0.7"

  # This gives you the chance to run a REPL inside your tests
  # via:
  #
  #    require 'pry'
  #    binding.pry
  #
  # This will stop test execution and let you inspect the results
  spec.add_development_dependency "pry"
end
