# multi_version_common_cartridge
# Copyright © 2019 Vista Higher Learning, Inc.
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
  class Cartridge
    attr_accessor :items

    def initialize
      @items = []
      @resources = []
    end

    def manifest
      @manifest ||= Manifest.new
    end

    def add_item(item)
      @items << item
    end

    def all_items
      @all_items ||= begin
                       @items.each_with_object([]) do |item, memo|
                         memo << item
                         child_items(item, memo)
                       end
                     end.flatten
    end

    def add_resource(resource)
      @resources << resource
    end

    def all_resources
      @all_resources ||= get_resources
    end

    private def child_items(item, memo)
      item.children.each do |child|
        memo << child
        child_items(child, memo)
      end
    end

    private

    def get_resources
      all_resources = all_items.flat_map do |item|
        next if item.resource.nil?

        item.resource.dependencies << item.resource
      end

      all_resources.compact + @resources
    end
  end
end
