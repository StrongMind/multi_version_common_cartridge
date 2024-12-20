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
    class CanvasAssignmentWriter < ResourceWriter
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

      CANVAS_ASSIGNMENT_FILENAME = 'assignment_settings.xml'.freeze
      CANVAS_ASSIGNMENT_HTML_FILENAME = 'assignment.html'.freeze

      def finalize
        super
        validate_title
        validate_external_tool_url
      end

      def type
        'associatedcontent/imscc_xmlv1p1/learning-application-resource'
      end

      def files
        [
          File.join(resource_path, CANVAS_ASSIGNMENT_FILENAME),
          File.join(resource_path, CANVAS_ASSIGNMENT_HTML_FILENAME)
        ]
      end

      def create_files(out_dir)
        FileUtils.mkdir_p(File.join(out_dir, resource_path))
        doc = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |builder|
          SaxMachineNokogiriXmlSaver.new.save(
            builder, canvas_assignment_element, 'assignment'
          )
        end
        File.open(File.join(out_dir, resource_path, CANVAS_ASSIGNMENT_FILENAME), 'w') do |file|
          file.write(doc.to_xml)
        end

        File.open(File.join(out_dir, resource_path, CANVAS_ASSIGNMENT_HTML_FILENAME), 'w') do |file|
          file.write("<p></p>")
        end
      end

      def canvas_assignment_element
        @canvas_assignment_element ||=
          MultiVersionCommonCartridge::Elements::Canvas::Assignment.new.tap do |element|
            element.xmlns = required_namespaces['xmlns']
            element.xmlns_xsi = required_namespaces['xmlns:xsi']
            element.identifier = resource.identifier
            element.title = resource.title
            element.assignment_group_identifierref = resource.assignment_group_identifierref
            element.points_possible = resource.points_possible
            element.max_attempts = resource.max_attempts
            element.allowed_attempts = resource.allowed_attempts
            element.is_end_of_module_exam = resource.is_end_of_module_exam
            element.grading_type = resource.grading_type
            element.submission_types = resource.submission_types
            element.peer_review_count = resource.peer_review_count
            element.external_tool_url = resource.external_tool_url
          end
      end

      private def validate_title
        raise StandardError, MESSAGES[:no_title] unless resource.title
      end

      private def validate_external_tool_url
        raise StandardError, MESSAGES[:no_external_tool_url] unless resource.external_tool_url
      end

      private def required_namespaces
        REQUIRED_NAMESPACES[@version]
      end

      private def resource_path
        resource.identifier
      end
    end
  end
end
