# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'icmp/version'

Gem::Specification.new do |spec|
  spec.name          = 'icmp'
  spec.version       = Icmp::VERSION
  spec.authors       = ['Artem Baikuzin']
  spec.email         = ['artembaykuzin@gmail.com']

  spec.summary       = %q{Interactive comparison of two sorted arrays}
  spec.description   = %q{Compare two arrays in interactive way, yields block with arguments: event, current_item, previous_item. Takes O(n) time.}
  spec.homepage      = 'https://github.com/ybinzu/icmp'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|benchmark)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
