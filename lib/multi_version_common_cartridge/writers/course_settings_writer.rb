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
    class CourseSettingsWriter < ResourceWriter
      REQUIRED_NAMESPACES = {
        MultiVersionCommonCartridge::CartridgeVersions::CC_1_1_0 => {
          'xmlns' => 'http://canvas.instructure.com/xsd/cccv1p0',
          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance'
        }
      }.freeze

      COURSE_SETTINGS_FILENAME = 'course_settings.xml'.freeze

      def type
        'webcontent'
      end

      def files
        [
          File.join(resource_path, COURSE_SETTINGS_FILENAME)
        ]
      end

      def create_files(out_dir)
        FileUtils.mkdir_p(File.join(out_dir, resource_path))
        doc = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |builder|
          SaxMachineNokogiriXmlSaver.new.save(
            builder, course_settings_element, 'assignment'
          )
        end
        File.open(File.join(out_dir, resource_path, COURSE_SETTINGS_FILENAME), 'w') do |file|
          file.write(doc.to_xml)
        end
      end

      def course_settings_element
        @course_settings_element ||=
          CanvasCartridge::Elements::Resources::CourseSettings::CourseSettings.new.tap do |element|
            element.xmlns = required_namespaces['xmlns']
            element.xmlns_xsi = required_namespaces['xmlns:xsi']
            element.image_url = resource.image_url
            element.group_weighting_scheme = resource.group_weighting_scheme
          end
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
