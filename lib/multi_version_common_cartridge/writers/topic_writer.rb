# frozen_string_literal: true

module MultiVersionCommonCartridge
  module Writers
    class TopicWriter < ResourceWriter
      include SupportedVersions

      attr_reader :topic

      def initialize(topic, version)
        super
        @topic = topic
        @version = validate_version(version)
      end

      def write(dir)
        doc = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |builder|
          SaxMachineNokogiriXmlSaver.new.save(builder, topic_element, 'topic')
        end
        File.write(File.join(dir, 'topic.xml'), doc.to_xml)
      end

      def topic_element
        @topic_element ||= MultiVersionCommonCartridge::Elements::Topic.new.tap do |element|
          element.xmlns_xsi = required_namespaces['xmlns:xsi']
          element.xmlns = required_namespaces['xmlns:imsdt']
          element.title = topic.title
          element.text = MultiVersionCommonCartridge::Elements::TopicText.new.tap do |text|
            text.text = topic.text
            text.type = 'text/html'
          end
        end
      end

      private def required_namespaces
        XmlDefinitions::REQUIRED_NAMESPACES[@version]
      end

    end
  end
end
