# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kociemba/version'

Gem::Specification.new do |spec|
  spec.name          = "kociemba"
  spec.version       = Kociemba::VERSION
  spec.authors       = ["Stafford Brunk"]
  spec.email         = ["wingrunr21@gmail.com"]

  spec.summary       = %q{Herbert Kociemba's Rubik's Cube algorithm}
  spec.description   = %q{A ruby implementation of Herbert Kociemba's 2 Phase Rubik's Cube algorithm}
  spec.homepage      = "https://github.com/wingrunr21/kociemba"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
