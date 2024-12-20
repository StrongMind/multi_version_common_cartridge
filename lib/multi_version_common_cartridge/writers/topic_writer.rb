# frozen_string_literal: true

module MultiVersionCommonCartridge
  module Writers
    class TopicWriter < ResourceWriter
      include SupportedVersions

      def type
        'imsdt_xmlv1p1'
      end

      def create_files(dir)
        doc = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |builder|
          SaxMachineNokogiriXmlSaver.new.save(builder, topic_element, 'topic')
        end
        File.write(File.join(dir, "#{resource.identifier}.xml"), doc.to_xml)
      end

      def topic_element
        @topic_element ||= MultiVersionCommonCartridge::Elements::Topic.new.tap do |element|
          element.xmlns_xsi = required_namespaces['xmlns:xsi']
          element.xmlns = required_namespaces['xmlns:imsdt']
          element.title = resource.title
          element.text = MultiVersionCommonCartridge::Elements::TopicText.new.tap do |text|
            text.text = resource.text
            text.type = 'text/html'
          end
        end
      end

      def files
        [
          "#{topic.identifier}.xml"
        ]
      end

      private def required_namespaces
        XmlDefinitions::REQUIRED_NAMESPACES[@version]
      end

    end
  end
end
