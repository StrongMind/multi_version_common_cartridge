describe MultiVersionCommonCartridge::Writers::TopicWriter do
  describe '#write' do
    subject(:write) { topic_writer.write(dir) }

    let(:topic_writer) { described_class.new(version) }
    let(:version) { MultiVersionCommonCartridge::CartridgeVersions::CC_1_2_0 }
    let(:dir) { Dir.mktmpdir }
    let(:topic_element) { topic_writer.topic_element }
    let(:xml_file) { Nokogiri.parse(File.read("#{dir}/topic.xml")) }

    it 'produces a file with a root element called topic' do
      write
      expect(File.read("#{dir}/topic.xml")).to include('<topic>')
    end

    it 'has a root element called topic' do
      write
      expect(xml_file.root.name).to eq('topic')
    end

    it 'has namespaces on the root element' do
      write
      expect(xml_file.root.namespace.href).to eq('http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1')
      expect(xml_file.root.namespace_definitions.find { |ns| ns.prefix == 'xsi' }.href).to eq('http://www.w3.org/2001/XMLSchema-instance')
    end

    context 'when the export version 1.2.0' do
      let(:version) { MultiVersionCommonCartridge::CartridgeVersions::CC_1_2_0 }

      let(:required_namespaces) do
        MultiVersionCommonCartridge::XmlDefinitions::REQUIRED_NAMESPACES[version]
      end

      it 'sets the required namespaces' do
        write
        expect(topic_element.xmlns_xsi).to eq(required_namespaces['xmlns:xsi'])
        expect(topic_element.xmlns).to eq(required_namespaces['xmlns:imsdt'])
      end
    end

    context 'when the export version 1.1.0' do
      let(:version) { MultiVersionCommonCartridge::CartridgeVersions::CC_1_1_0 }

      let(:required_namespaces) do
        MultiVersionCommonCartridge::XmlDefinitions::REQUIRED_NAMESPACES[version]
      end

      it 'sets the required namespaces' do
        write
        expect(topic_element.xmlns_xsi).to eq(required_namespaces['xmlns:xsi'])
        expect(topic_element.xmlns).to eq(required_namespaces['xmlns:imsdt'])
      end
    end


  end
end
