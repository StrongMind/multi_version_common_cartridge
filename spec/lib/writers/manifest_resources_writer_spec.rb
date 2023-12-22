require 'spec_helper'
require 'multi_version_common_cartridge'

describe MultiVersionCommonCartridge::Writers::ManifestResourcesWriter do
  let(:cartridge) { MultiVersionCommonCartridge::Cartridge.new }
  let(:version) { MultiVersionCommonCartridge::CartridgeVersions::CC_1_3_0 }
  let(:writers_factory) { MultiVersionCommonCartridge::Writers::Factory.new(cartridge, version) }
  let(:writer) { described_class.new(cartridge, writers_factory, version) }

  describe '#initialize' do
    context 'when a non supported version is specified,' do
      let(:version) { 'some random version' }

      it 'raises an error' do
        expect { writer }.to raise_error(
                               ArgumentError,
                               format(described_class::UNSUPPORTED_VERSION_MSG_TEMPLATE, version: version)
                             )
      end
    end

    context 'when a supported version is specified,' do
      it 'does not raise an error' do
        described_class::SUPPORTED_VERSIONS.each do |version|
          factory = MultiVersionCommonCartridge::Writers::Factory.new(cartridge, version)
          expect { described_class.new(cartridge, factory, version) }.not_to raise_error
        end
      end
    end
  end

  describe '#finalize' do
    it 'does no raise an error' do
      expect { writer.finalize }.not_to raise_error
    end
  end

  context 'when finalizing for version 1.3.0,' do
    let(:version) { MultiVersionCommonCartridge::CartridgeVersions::CC_1_3_0 }
    let(:identifier) { 'some identifier' }
    let(:resources) do
      Array.new(3) { MultiVersionCommonCartridge::Resources::BasicLtiLink::BasicLtiLink.new }
    end
    let(:resource_writers) do
      resources.map { instance_double(MultiVersionCommonCartridge::Writers::BasicLtiLinkWriter) }
    end
    let(:resource_elements) do
      resources.map { CommonCartridge::Elements::Resources::Resource.new }
    end

    before do
      allow(cartridge).to receive(:all_resources).and_return(resources)
      resources.each_with_index do |resource, index|
        resource_writer = resource_writers[index]
        resource_element = resource_elements[index]

        allow(resource_writer).to receive(:finalize)
        allow(resource_writer).to receive(:resource_element).and_return(resource_element)
        allow(MultiVersionCommonCartridge::Writers::ResourceWriter)
          .to receive(:new).with(resource, version).and_return(resource_writer)
      end
    end

    describe '#root_resource_element' do
      it 'returns a RootResource element' do
        expect(writer.root_resource_element)
          .to be_a(CommonCartridge::Elements::Resources::RootResource)
      end

      it 'sets the organization root items' do
        writer.finalize
        expect(writer.root_resource_element.resources).to eq(resource_elements)
      end
    end
  end

  context 'when finalizing canvas course' do
    let(:version) { MultiVersionCommonCartridge::CartridgeVersions::CC_1_1_0 }
    let(:identifier) { 'some identifier' }
    let(:href) { 'some href' }
    let(:image_url) { 'some image url' }
    let(:group_weighting_scheme) { 'some group weighting scheme' }
    let(:canvas_resource) do
      ccs = MultiVersionCommonCartridge::Resources::CanvasCourseSettings::CanvasCourseSettings.new
      ccs.href = href
      ccs.identifier = identifier
      ccs.image_url = image_url
      ccs.group_weighting_scheme = group_weighting_scheme
      ccs
    end

    before do
      cartridge.add_resource(canvas_resource)

      writer.finalize
    end

    it 'has a resource element for the canvas course settings' do
      expect(writer.root_resource_element.resources.count).to eq(1)
    end

    it 'has the identifier' do
      expect(writer.root_resource_element.resources.first.identifier).to eq(identifier)
    end

    it 'has the href' do
      expect(writer.root_resource_element.resources.first.href).to eq(href)
    end

    it 'has the type' do
      expect(writer.root_resource_element.resources.first.type).to eq('webcontent')
    end

    it 'has the files' do
      expect(writer.root_resource_element.resources.first.files.count).to eq(4)
    end

    it 'has the course settings file' do
      expect(writer.root_resource_element.resources.first.files[0].href).to eq('course_settings/course_settings.xml')
    end

    it 'has the canvas export file' do
      expect(writer.root_resource_element.resources.first.files[1].href).to eq('course_settings/canvas_export.txt')
    end

    it 'has the assignment groups file' do
      expect(writer.root_resource_element.resources.first.files[2].href).to eq('course_settings/assignment_groups.xml')
    end

    it 'has the module meta file' do
      expect(writer.root_resource_element.resources.first.files[3].href).to eq('course_settings/module_meta.xml')
    end

  end
end
