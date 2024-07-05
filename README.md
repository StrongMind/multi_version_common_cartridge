# multi_version_common_cartridge
A gem for writing different versions of Common Cartridges.

It supports Common Cartridge version 1.1, 1.2, 1.3 and Thin CC version 1.2 and 1.3.

## Installation
[Ruby Gems](https://rubygems.org/gems/strongmind_multi_version_common_cartridge)

Gemfile:
``` ruby
gem 'strongmind_multi_version_common_cartridge', '~> 1.0', '>= 1.0.5'
```

Direct Install:
``` ruby
gem install strongmind_multi_version_common_cartridge
```

## Usage
``` ruby
require 'multi_version_common_cartridge'

# Create a Common Cartridge
cartridge = MultiVersionCommonCartridge::Cartridge.new
cartridge.manifest.set_title('My cartridge')
cartridge.items = [
  MultiVersionCommonCartridge::Item.new.tap do |item|
    item.title = 'My activity'
    item.identifier = 'Some identifier'
    item.resource = MultiVersionCommonCartridge::Resources::BasicLtiLink::BasicLtiLink.new.tap do |lti|
      lti.title = 'My activity title'
      lti.identiier = 'My activity identifier'
      lti.scure_launch_url = 'https://example.com/lti'
    end
  end
]

# Create a Common Cartridge writer for version 1.2.0
writer = MultiVersionCommonCartridge::Writers::CartridgeWriter.new(
  cartridge, '1.2.0'
end

# Finalize the Common Cartridge for the specified version.
writer.finalize

# Check for error
return if writer.errors?

# Write the Common Cartridge
writer.write_to_zip('cartridge.imscc')
```
