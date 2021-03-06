# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'neofugo_client/version'

Gem::Specification.new do |spec|
  spec.name          = "neofugo_client"
  spec.version       = NeofugoClient::VERSION
  spec.authors       = ["pocari"]
  spec.email         = ["caffelattenonsugar@gmail.com"]

  spec.summary       = %q{Neofugo client by ruby}
  spec.description   = %q{This library can implement Neofugo Client easy.}
  spec.homepage      = "https://github.com/pocari"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"

  spec.add_dependency "websocket-client-simple", "~> 0.2.2"
end
