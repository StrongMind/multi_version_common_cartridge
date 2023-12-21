require 'spec_helper'
require 'multi_version_common_cartridge'

describe MultiVersionCommonCartridge::Writers::CourseSettingsWriter do
  let(:course_settings) { MultiVersionCommonCartridge::Resources::CourseSettings::CourseSettings.new }
  let(:course_settings_writer) { described_class.new(course_settings, version) }
  let(:version) { MultiVersionCommonCartridge::CartridgeVersions::CC_1_1_0 }
  let(:identifier) { 'some identifier' }
  let(:image_url) { 'some image url' }
  let(:group_weighting_scheme) { 'percent' }

  describe '#type' do
    it 'returns the webcontent type' do
      expect(course_settings_writer.type).to eq('webcontent')
    end
  end

  describe '#initialize' do
    context 'when a non supported version is specified,' do
      let(:version) { 'some random version' }

      it 'raises an error' do
        expect { course_settings_writer }.to raise_error(
                                               ArgumentError,
                                               format(described_class::UNSUPPORTED_VERSION_MSG_TEMPLATE, version: version)
                                             )
      end
    end

    context 'when a supported version is specified,' do
      it 'does not raise an error' do
        described_class::SUPPORTED_VERSIONS.each do |version|
          expect { described_class.new(course_settings, version) }.not_to raise_error
        end
      end
    end
  end

  describe '#finalize' do
    context 'when no identifier is set,' do
      it 'creates a random identifier' do
        course_settings_writer.finalize
        expect(course_settings.identifier).not_to be_empty
      end
    end

    context 'when an identifier is set,' do
      it 'does not change the identifier' do
        course_settings.identifier = identifier
        course_settings_writer.finalize
        expect(course_settings.identifier).to eq(identifier)
      end
    end

  end

  context 'when finalizing for version 1.1.0,' do
    let(:version) { MultiVersionCommonCartridge::CartridgeVersions::CC_1_1_0 }
    let(:assignment_element) { course_settings_writer.course_settings_element }

    before do
      course_settings.identifier = identifier
      course_settings.image_url = image_url
      course_settings.group_weighting_scheme = group_weighting_scheme
      course_settings_writer.finalize
    end

    describe '#course_settings_element' do
      let(:required_namespaces) do
        described_class::REQUIRED_NAMESPACES[version]
      end
      let(:required_schema_locations) do
        described_class::REQUIRED_SCHEMA_LOCATIONS[version]
      end

      it 'returns a course settings element' do
        expect(assignment_element).to be_a(CanvasCartridge::Elements::Resources::CourseSettings::CourseSettings)
      end

      it 'sets the required xml namespaces' do
        expect(assignment_element.xmlns).to eq(required_namespaces['xmlns'])
        expect(assignment_element.xmlns_xsi).to eq(required_namespaces['xmlns:xsi'])
      end

      it 'sets the assignment element image url' do
        expect(assignment_element.image_url).to eq(image_url)
      end

      it 'sets the assignment element group weighting scheme' do
        expect(assignment_element.group_weighting_scheme).to eq(group_weighting_scheme)
      end
    end
  end

  describe '#create_files' do
    let(:nokogiri_builder) { instance_double(Nokogiri::XML::Builder) }
    let(:xml_saver) { instance_double(SaxMachineNokogiriXmlSaver) }
    let(:xml_content) { 'xml content' }

    before do
      allow(Nokogiri::XML::Builder)
        .to receive(:new)
              .with(encoding: 'UTF-8')
              .and_yield(nokogiri_builder)
              .and_return(nokogiri_builder)
      allow(SaxMachineNokogiriXmlSaver).to receive(:new).and_return(xml_saver)
      allow(xml_saver).to receive(:save)
      allow(nokogiri_builder).to receive(:to_xml).and_return(xml_content)

      course_settings.identifier = identifier
    end

    it 'creates a sub directory with the resource identifier' do
      Dir.mktmpdir do |dir|
        sub_dir = File.join(dir, 'course_settings')
        course_settings_writer.create_files(dir)
        expect(File).to be_directory(sub_dir)
      end
    end

    it 'creates a xml file with the assignment element' do
      Dir.mktmpdir do |dir|
        sub_dir = File.join(dir, 'course_settings')
        course_settings_filename = File.join(sub_dir, 'course_settings.xml')
        course_settings_writer.create_files(dir)
        expect(File.read(course_settings_filename)).to eq(xml_content)
      end
    end
  end
end
