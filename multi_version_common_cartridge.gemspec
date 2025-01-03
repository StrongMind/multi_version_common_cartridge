lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'multi_version_common_cartridge/version'

Gem::Specification.new do |spec|
  spec.name = 'strongmind_multi_version_common_cartridge'
  spec.version = MultiVersionCommonCartridge::VERSION
  spec.authors = ['StrongMind']
  spec.email = ['vendor@strongmind.com']
  spec.summary = 'Creates IMS Common Cartridge files, supporting ' \
    'several versions of the CC standard.'
  spec.description = 'Target versions supported: 1.1, 1.2, 1.3; Thin 1.2, 1.3'
  spec.homepage = 'https://github.com/StrongMind/multi_version_common_cartridge'

  spec.require_paths = ["lib"]

  spec.files = `git ls-files -z`.split("\x0").reject do |file|
    file.match(%r{^(test|spec|features)/})
  end

  spec.add_dependency 'activesupport', '> 2.0'
  spec.add_dependency 'common_cartridge_parser', '~> 1.0.9'

  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov', '~> 0.22'
end
