# frozen_string_literal: true

module MultiVersionCommonCartridge
  module Writers
    class TopicWriter
      include SupportedVersions

      attr_reader :topic

      def initialize(version)
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
        end
      end

      private def required_namespaces
        XmlDefinitions::REQUIRED_NAMESPACES[@version]
      end

    end
  end
end
