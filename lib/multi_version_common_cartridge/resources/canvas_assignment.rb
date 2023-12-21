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
        attr_accessor :title, :external_tool_url

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
