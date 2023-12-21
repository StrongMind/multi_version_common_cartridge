require 'spec_helper'
require 'multi_version_common_cartridge'

describe MultiVersionCommonCartridge::Writers::CanvasAssignmentWriter do
  let(:canvas_assignment) { MultiVersionCommonCartridge::Resources::CanvasAssignment::CanvasAssignment.new }
  let(:canvas_assignment_writer) { described_class.new(canvas_assignment, version) }
  let(:version) { MultiVersionCommonCartridge::CartridgeVersions::CC_1_1_0 }
  let(:identifier) { 'some identifier' }
  let(:title) { 'some title' }
  let(:assignment_group_identifierref) { 'some assignment group identifierref' }
  let(:points_possible) { 100 }
  let(:max_attempts) { 1 }
  let(:allowed_attempts) { 1 }
  let(:is_end_of_module_exam) { false }
  let(:grading_type) { 'points' }
  let(:submission_type) { 'external_tool' }
  let(:peer_review_count) { 0 }
  let(:external_tool_url) { 'some external tool url' }

  describe '#type' do
    it 'returns the learning application resource type' do
      expect(canvas_assignment_writer.type).to eq('associatedcontent/imscc_xmlv1p1/learning-application-resource')
    end
  end

  describe '#initialize' do
    context 'when a non supported version is specified,' do
      let(:version) { 'some random version' }

      it 'raises an error' do
        expect { canvas_assignment_writer }.to raise_error(
                                                 ArgumentError,
                                                 format(described_class::UNSUPPORTED_VERSION_MSG_TEMPLATE, version: version)
                                               )
      end
    end

    context 'when a supported version is specified,' do
      it 'does not raise an error' do
        described_class::SUPPORTED_VERSIONS.each do |version|
          expect { described_class.new(canvas_assignment, version) }.not_to raise_error
        end
      end
    end
  end

  describe '#finalize' do
    context 'when no identifier is set,' do
      it 'creates a random identifier' do
        canvas_assignment.title = title
        canvas_assignment.external_tool_url = external_tool_url
        canvas_assignment_writer.finalize
        expect(canvas_assignment.identifier).not_to be_empty
      end
    end

    context 'when an identifier is set,' do
      it 'does not change the identifier' do
        canvas_assignment.identifier = identifier
        canvas_assignment.title = title
        canvas_assignment.external_tool_url = external_tool_url
        canvas_assignment_writer.finalize
        expect(canvas_assignment.identifier).to eq(identifier)
      end
    end

    context 'when no title is set,' do
      it 'raises an error' do
        canvas_assignment.identifier = identifier
        canvas_assignment.external_tool_url = external_tool_url
        expect { canvas_assignment_writer.finalize }.to raise_error(
                                                          StandardError,
                                                          described_class::MESSAGES[:no_title]
                                                        )
      end
    end

    context 'when a title is set,' do
      it 'does not raise an error' do
        canvas_assignment.identifier = identifier
        canvas_assignment.title = title
        canvas_assignment.external_tool_url = external_tool_url
        expect { canvas_assignment_writer.finalize }.not_to raise_error
      end
    end
  end

  context 'when finalizing for version 1.1.0,' do
    let(:version) { MultiVersionCommonCartridge::CartridgeVersions::CC_1_1_0 }
    let(:assignment_element) { canvas_assignment_writer.canvas_assignment_element }

    before do
      canvas_assignment.identifier = identifier
      canvas_assignment.title = title
      canvas_assignment.assignment_group_identifierref = assignment_group_identifierref
      canvas_assignment.points_possible = points_possible
      canvas_assignment.max_attempts = max_attempts
      canvas_assignment.allowed_attempts = allowed_attempts
      canvas_assignment.is_end_of_module_exam = is_end_of_module_exam
      canvas_assignment.grading_type = grading_type
      canvas_assignment.submission_type = submission_type
      canvas_assignment.peer_review_count = peer_review_count
      canvas_assignment.external_tool_url = external_tool_url
      canvas_assignment_writer.finalize
    end

    describe '#canvas_assignment_element' do
      let(:required_namespaces) do
        described_class::REQUIRED_NAMESPACES[version]
      end
      let(:required_schema_locations) do
        described_class::REQUIRED_SCHEMA_LOCATIONS[version]
      end

      it 'returns a canvas assignment element' do
        expect(assignment_element).to be_a(CanvasCartridge::Elements::Resources::CanvasAssignment::CanvasAssignment)
      end

      it 'sets the required xml namespaces' do
        expect(assignment_element.xmlns).to eq(required_namespaces['xmlns'])
        expect(assignment_element.xmlns_xsi).to eq(required_namespaces['xmlns:xsi'])
      end

      it 'sets the assignment element title' do
        expect(assignment_element.title).to eq(title)
      end

      it 'sets the assignment element assignment_group_identifierref' do
        expect(assignment_element.assignment_group_identifierref).to eq(assignment_group_identifierref)
      end

      it 'sets the assignment element points possible' do
        expect(assignment_element.points_possible).to eq(points_possible)
      end

      it 'sets the assignment element max attempts' do
        expect(assignment_element.max_attempts).to eq(max_attempts)
      end

      it 'sets the assignment element allowed attempts' do
        expect(assignment_element.allowed_attempts).to eq(allowed_attempts)
      end

      it 'sets the assignment element is end of module exam' do
        expect(assignment_element.is_end_of_module_exam).to eq(is_end_of_module_exam)
      end

      it 'sets the assignment element grading type' do
        expect(assignment_element.grading_type).to eq(grading_type)
      end

      it 'sets the assignment element submission type' do
        expect(assignment_element.submission_type).to eq(submission_type)
      end

      it 'sets the assignment element peer review count' do
        expect(assignment_element.peer_review_count).to eq(peer_review_count)
      end

      it 'sets the assignment element external tool url' do
        expect(assignment_element.external_tool_url).to eq(external_tool_url)
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

      canvas_assignment.identifier = identifier
    end

    it 'creates a sub directory with the resource identifier' do
      Dir.mktmpdir do |dir|
        sub_dir = File.join(dir, canvas_assignment.identifier)
        canvas_assignment_writer.create_files(dir)
        expect(File).to be_directory(sub_dir)
      end
    end

    it 'creates a xml file with the assignment element' do
      Dir.mktmpdir do |dir|
        sub_dir = File.join(dir, canvas_assignment.identifier)
        assignment_settings_filename = File.join(sub_dir, 'assignment_settings.xml')
        canvas_assignment_writer.create_files(dir)
        expect(File.read(assignment_settings_filename)).to eq(xml_content)
      end
    end
  end
end
