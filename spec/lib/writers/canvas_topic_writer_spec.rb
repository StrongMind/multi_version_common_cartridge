require 'spec_helper'
require 'multi_version_common_cartridge'

describe MultiVersionCommonCartridge::Writers::CanvasTopicWriter do
  let(:canvas_topic) { MultiVersionCommonCartridge::Resources::CanvasTopic.new }
  let(:canvas_topic_writer) { described_class.new(canvas_topic, version) }
  let(:canvas_assignment) { MultiVersionCommonCartridge::Resources::CanvasAssignment::CanvasAssignment.new }
  let(:version) { MultiVersionCommonCartridge::CartridgeVersions::CC_1_1_0 }
  let(:identifier) { 'some identifier' }
  let(:title) { 'some title' }
  let(:assignment_group_identifierref) { 'some assignment group identifierref' }
  let(:points_possible) { 100 }
  let(:max_attempts) { 1 }
  let(:allowed_attempts) { 1 }
  let(:is_end_of_module_exam) { false }
  let(:grading_type) { 'points' }
  let(:submission_types) { 'external_tool' }
  let(:peer_review_count) { 0 }
  let(:position) { 0 }
  let(:workflow_state) { 'active' }
  let(:discussion_type) { 'threaded' }
  let(:type) { 'topic' }
  let(:xml_file) { Nokogiri.parse(File.read("#{dir}/#{identifier}_canvasTopic.xml")) }

  describe '#initialize' do
    context 'when a non supported version is specified,' do
      let(:version) { 'some random version' }

      it 'raises an error' do
        expect { canvas_topic_writer }.to raise_error(
                                            ArgumentError,
                                            format(described_class::UNSUPPORTED_VERSION_MSG_TEMPLATE, version: version)
                                          )
      end
    end

    context 'when a supported version is specified,' do
      it 'does not raise an error' do
        described_class::SUPPORTED_VERSIONS.each do |version|
          expect { described_class.new(canvas_topic, version) }.not_to raise_error
        end
      end
    end
  end

  describe '#finalize' do
    context 'when no identifier is set,' do
      it 'creates a random identifier' do
        canvas_topic.title = title
        canvas_topic_writer.finalize
        expect(canvas_topic.identifier).not_to be_empty
      end
    end

    context 'when an identifier is set,' do
      it 'does not change the identifier' do
        canvas_topic.identifier = identifier
        canvas_topic.title = title
        canvas_topic_writer.finalize
        expect(canvas_topic.identifier).to eq(identifier)
      end
    end

    context 'when no title is set,' do
      it 'raises an error' do
        canvas_topic.identifier = identifier
        expect { canvas_topic_writer.finalize }.to raise_error(
                                                     StandardError,
                                                     described_class::MESSAGES[:no_title]
                                                   )
      end
    end

    context 'when a title is set,' do
      it 'does not raise an error' do
        canvas_topic.identifier = identifier
        canvas_topic.title = title
        expect { canvas_topic_writer.finalize }.not_to raise_error
      end
    end
  end

  context 'when finalizing for version 1.1.0,' do
    let(:version) { MultiVersionCommonCartridge::CartridgeVersions::CC_1_1_0 }
    let(:topic_element) { canvas_topic_writer.canvas_topic_element }

    before do
      canvas_topic.identifier = identifier
      canvas_topic.title = title
      canvas_topic.assignment = canvas_assignment
      canvas_assignment.assignment_group_identifierref = assignment_group_identifierref
      canvas_assignment.points_possible = points_possible
      canvas_assignment.max_attempts = max_attempts
      canvas_assignment.allowed_attempts = allowed_attempts
      canvas_assignment.is_end_of_module_exam = is_end_of_module_exam
      canvas_assignment.grading_type = grading_type
      canvas_assignment.submission_types = submission_types
      canvas_assignment.peer_review_count = peer_review_count
      canvas_topic.position = position
      canvas_topic.workflow_state = workflow_state
      canvas_topic.discussion_type = discussion_type
      canvas_topic.type = type
      canvas_topic_writer.finalize
    end

    describe '#canvas_topic_element' do
      let(:required_namespaces) do
        described_class::REQUIRED_NAMESPACES[version]
      end
      let(:required_schema_locations) do
        described_class::REQUIRED_SCHEMA_LOCATIONS[version]
      end

      it 'returns a canvas assignment element' do
        expect(topic_element).to be_a(MultiVersionCommonCartridge::Elements::Canvas::TopicMeta)
      end

      it 'sets the required xml namespaces' do
        expect(topic_element.xmlns).to eq(required_namespaces['xmlns'])
        expect(topic_element.xmlns_xsi).to eq(required_namespaces['xmlns:xsi'])
      end

      it 'sets the title' do
        expect(topic_element.title).to eq(title)
      end

      it 'sets the element assignment_group_identifierref' do
        expect(topic_element.assignment.assignment_group_identifierref).to eq(assignment_group_identifierref)
      end

      it 'sets the element points possible' do
        expect(topic_element.assignment.points_possible).to eq(points_possible)
      end

      it 'sets the assignment element max attempts' do
        expect(topic_element.assignment.max_attempts).to eq(max_attempts)
      end

      it 'sets the assignment element allowed attempts' do
        expect(topic_element.assignment.allowed_attempts).to eq(allowed_attempts)
      end

      it 'sets the assignment element is end of module exam' do
        expect(topic_element.assignment.is_end_of_module_exam).to eq(is_end_of_module_exam)
      end

      it 'sets the assignment element grading type' do
        expect(topic_element.assignment.grading_type).to eq(grading_type)
      end

      it 'sets the assignment element submission type' do
        expect(topic_element.assignment.submission_types).to eq(submission_types)
      end

      it 'sets the assignment element peer review count' do
        expect(topic_element.assignment.peer_review_count).to eq(peer_review_count)
      end

      it 'sets the position' do
        expect(topic_element.position).to eq(position)
      end

      it 'sets the workflow state' do
        expect(topic_element.workflow_state).to eq(workflow_state)
      end

      it 'sets the discussion type' do
        expect(topic_element.discussion_type).to eq(discussion_type)
      end

      it 'sets the type' do
        expect(topic_element.type).to eq(type)
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

      canvas_topic.identifier = identifier
      canvas_topic.assignment = canvas_assignment
    end

    it 'creates a xml file with the assignment element' do
      Dir.mktmpdir do |dir|
        filename = File.join(dir, "#{canvas_topic.identifier}_canvasTopic.xml")
        canvas_topic_writer.create_files(dir)
        expect(File.read(filename)).to eq(xml_content)
      end
    end
  end
end
