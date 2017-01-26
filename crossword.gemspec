# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crossword/version'

Gem::Specification.new do |spec|
  spec.name          = "crossword"
  spec.version       = Crossword::VERSION
  spec.authors       = ["Andrew Stephenson"]
  spec.email         = ["Andrew.Stephenson123@gmail.com"]

  spec.summary       = %q{Simple Crossword Puzzle Generation for Ruby}
  spec.description   = %q{A library intended to simplify crossword puzzle generation in ruby.}
  spec.homepage      = "https://github.com/andrewls/crossword.rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_dependency 'minitest-byebug'
  spec.add_dependency 'byebug'
  spec.add_dependency 'pqueue'
end
