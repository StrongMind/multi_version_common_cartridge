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
    class CanvasCourseSettingsWriter < ResourceWriter
      REQUIRED_NAMESPACES = {
        MultiVersionCommonCartridge::CartridgeVersions::CC_1_1_0 => {
          'xmlns' => 'http://canvas.instructure.com/xsd/cccv1p0',
          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance'
        }
      }.freeze

      COURSE_SETTINGS_FILENAME = 'course_settings.xml'.freeze
      CANVAS_EXPORT_FILENAME = 'canvas_export.txt'.freeze
      ASSIGNMENT_GROUPS_FILENAME = 'assignment_groups.xml'.freeze

      def type
        'webcontent'
      end

      def files
        [
          File.join(resource_path, COURSE_SETTINGS_FILENAME),
          File.join(resource_path, CANVAS_EXPORT_FILENAME),
          File.join(resource_path, ASSIGNMENT_GROUPS_FILENAME),
        ]
      end

      def create_files(out_dir)
        FileUtils.mkdir_p(File.join(out_dir, resource_path))
        course_settings_doc = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |builder|
          SaxMachineNokogiriXmlSaver.new.save(
            builder, course_settings_element, 'course'
          )
        end
        assignment_groups_doc = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |builder|
          SaxMachineNokogiriXmlSaver.new.save(
            builder, assignment_groups_element, 'assignmentGroups'
          )
        end
        File.open(File.join(out_dir, resource_path, COURSE_SETTINGS_FILENAME), 'w') do |file|
          file.write(course_settings_doc.to_xml)
        end

        File.open(File.join(out_dir, resource_path, CANVAS_EXPORT_FILENAME), 'w') do |file|
          file.write(canvas_export_contents)
        end

        File.open(File.join(out_dir, resource_path, ASSIGNMENT_GROUPS_FILENAME), 'w') do |file|
          file.write(assignment_groups_doc.to_xml)
        end
      end

      def course_settings_element
        @course_settings_element ||=
          CanvasCartridge::Elements::Resources::CourseSettings::CourseSettings.new.tap do |element|
            element.identifier = resource.identifier
            element.xmlns = required_namespaces['xmlns']
            element.xmlns_xsi = required_namespaces['xmlns:xsi']
            element.image_url = resource.image_url
            element.group_weighting_scheme = resource.group_weighting_scheme
          end
      end

      def assignment_groups_element
        @assignment_groups_element ||=
          CanvasCartridge::Elements::Resources::CourseSettings::AssignmentGroups.new.tap do |element|
            element.xmlns = required_namespaces['xmlns']
            element.xmlns_xsi = required_namespaces['xmlns:xsi']
            element.groups = groups_child_elements
          end
      end

      def groups_child_elements
        return if resource.assignment_groups.nil?

        resource.assignment_groups.map do |key, value|
          CanvasCartridge::Elements::Resources::CourseSettings::AssignmentGroup.new.tap do |element|
            element.identifier = key
            element.title = value[:title]
            element.position = value[:position]
            element.group_weight = value[:group_weight]
          end
        end
      end

      def canvas_export_contents
        'What did the panda say when he was forced out of his natural habitat? Bamboo-zled!'
      end

      private def validate_external_tool_url
        raise StandardError, MESSAGES[:no_external_tool_url] unless resource.external_tool_url
      end

      private def required_namespaces
        REQUIRED_NAMESPACES[@version]
      end

      private def resource_path
        'course_settings'
      end
    end
  end
end
