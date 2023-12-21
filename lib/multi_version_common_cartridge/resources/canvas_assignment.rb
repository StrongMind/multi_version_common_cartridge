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
  module Resources
    module CanvasAssignment

      class CanvasAssignment < MultiVersionCommonCartridge::Resources::Resource
        attr_accessor :title, :assignment_group_identifierref, :points_possible, :max_attempts, :allowed_attempts,
                      :is_end_of_module_exam, :grading_type, :submission_type, :peer_review_count, :external_tool_url

        def initialize; end

      end
    end
  end
end
module CanvasCartridge
  module Elements
    module Resources
      module CanvasAssignment

        class CanvasAssignment
          attr_accessor :identifier

          include SAXMachine

          attribute :xmlns
          attribute 'xmlns:xsi', as: :xmlns_xsi

          element 'title', as: :title
          element 'assignment_group_identifierref', as: :assignment_group_identifierref
          element 'points_possible', as: :points_possible
          element 'max_attempts', as: :max_attempts
          element 'allowed_attempts', as: :allowed_attempts
          element 'is_end_of_module_exam', as: :is_end_of_module_exam
          element 'grading_type', as: :grading_type
          element 'submission_type', as: :submission_type
          element 'peer_review_count', as: :peer_review_count
          element 'external_tool_url', as: :external_tool_url

          def self.type
            :canvas_assignment
          end

          def self.pattern; end
        end
      end
    end
  end
end
