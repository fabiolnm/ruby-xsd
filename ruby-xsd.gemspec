# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby-xsd/version'

Gem::Specification.new do |gem|
  gem.name          = "ruby-xsd"
  gem.version       = Ruby::Xsd::VERSION
  gem.authors       = ["Fábio Luiz Nery de Miranda"]
  gem.email         = ["fabio@miranti.net.br"]
  gem.description   = %q{Generates in-memory ruby classes from XSD files}
  gem.summary       = %q{}
  gem.homepage      = "https://github.com/fabiolnm/ruby-xsd"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "debugger"
  gem.add_development_dependency "nokogiri"
  gem.add_development_dependency "activesupport"
  gem.add_development_dependency "activemodel"
end
