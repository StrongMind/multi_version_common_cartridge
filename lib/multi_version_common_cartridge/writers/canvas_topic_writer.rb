# multi_version_common_cartridge
# Copyright © 2023 StrongMind
#
# multi_version_common_cartridge is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation, either
# version 3 of the License, or (at your option) any later version.
#
# multi_version_common_cartridge is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with multi_version_common_cartridge.  If not, see <http://www.gnu.org/licenses/>.

module MultiVersionCommonCartridge
  module Writers
    class CanvasTopicWriter < ResourceWriter
      REQUIRED_NAMESPACES = {
        MultiVersionCommonCartridge::CartridgeVersions::CC_1_1_0 => {
          'xmlns' => 'http://canvas.instructure.com/xsd/cccv1p0',
          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance'
        }
      }.freeze

      MESSAGES = {
        no_title: 'A title is required.',
        no_external_tool_url: 'An external tool url is required.'
      }.freeze

      CANVAS_TOPIC_FILENAME_SUFFIX = '_canvasTopic.xml'.freeze

      def finalize
        super
        validate_title
      end

      def type
        'webcontent'
      end

      def create_files(out_dir)
        FileUtils.mkdir_p(File.join(out_dir))
        doc = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |builder|
          SaxMachineNokogiriXmlSaver.new.save(
            builder, canvas_topic_element, 'assignment'
          )
        end
        File.open(File.join(out_dir, "#{resource.identifier}#{CANVAS_TOPIC_FILENAME_SUFFIX}"), 'w') do |file|
          file.write(doc.to_xml)
        end

      end

      def canvas_topic_element
        @canvas_topic_element ||=
          MultiVersionCommonCartridge::Elements::Canvas::TopicMeta.new.tap do |element|
            element.xmlns = required_namespaces['xmlns']
            element.xmlns_xsi = required_namespaces['xmlns:xsi']
            element.identifier = resource.identifier
            element.title = resource.title
            assignment_resource = resource.assignment
            element.assignment = MultiVersionCommonCartridge::Elements::Canvas::Assignment.new.tap do |assignment|
              assignment.assignment_group_identifierref = assignment_resource.assignment_group_identifierref
              assignment.points_possible = assignment_resource.points_possible
              assignment.max_attempts = assignment_resource.max_attempts
              assignment.allowed_attempts = assignment_resource.allowed_attempts
              assignment.is_end_of_module_exam = assignment_resource.is_end_of_module_exam
              assignment.grading_type = assignment_resource.grading_type
              assignment.submission_types = assignment_resource.submission_types
              assignment.peer_review_count = assignment_resource.peer_review_count
            end

            element.position = resource.position
            element.workflow_state = resource.workflow_state
            element.discussion_type = resource.discussion_type
            element.type = resource.type

          end
      end

      def files
        [
          "#{resource.identifier}.xml"
        ]
      end

      private def validate_title
        raise StandardError, MESSAGES[:no_title] unless resource.title
      end

      private def required_namespaces
        REQUIRED_NAMESPACES[@version]
      end

    end
  end
end
