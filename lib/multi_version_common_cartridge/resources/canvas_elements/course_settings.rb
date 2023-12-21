module CanvasCartridge
  module Elements
    module Resources
      module CourseSettings

        class CourseSettings
          include SAXMachine

          attribute :identifier

          attribute :xmlns
          attribute 'xmlns:xsi', as: :xmlns_xsi

          element 'image_url', as: :image_url
          element 'group_weighting_scheme', as: :group_weighting_scheme

          def self.type
            :course_settings
          end

          def self.pattern; end
        end

        class AssignmentGroup
          include SAXMachine

          attribute :identifier

          element 'title', as: :title
          element 'position', as: :position
          element 'group_weight', as: :group_weight

        end

        class AssignmentGroups
          include SAXMachine

          attribute :xmlns
          attribute 'xmlns:xsi', as: :xmlns_xsi

          elements 'assignmentGroup', class: AssignmentGroup, as: :groups
        end
      end
    end
  end
end
