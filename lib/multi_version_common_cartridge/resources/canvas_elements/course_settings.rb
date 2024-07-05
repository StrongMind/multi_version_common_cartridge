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

        class Prerequisite
          include SAXMachine
          attribute :type
          element :title
          element :identifierref
        end

        class Prerequisites
          include SAXMachine

          elements :prerequisite, as: :prerequisites, class: Prerequisite
        end

        class Item
          include SAXMachine
          attribute :identifier, as: :identifier
          element :title
          element :workflow_state
          element :content_type
          element :identifierref
          element :url
          element :position
          element :indent
          element :global_identifierref
        end

        class Items
          include SAXMachine

          elements :item, as: :items, class: Item
        end

        class CompletionRequirement
          include SAXMachine
          attribute :type
          element :identifierref
        end

        class CompletionRequirements
          include SAXMachine

          elements :completionRequirement, as: :completion_requirements, class: CompletionRequirement
        end

        class Module
          include SAXMachine
          attribute :identifier
          element :title
          element :workflow_state
          element :position
          element :require_sequential_progress
          element :requirement_count
          element :prerequisites, as: :root_prerequisites, class: Prerequisites
          element :items, as: :root_items, class: Items
          element :completionRequirements, as: :root_requirements, class: CompletionRequirements
        end

        class Modules
          include SAXMachine

          attribute :xmlns
          attribute 'xmlns:xsi', as: :xmlns_xsi
          elements :module, as: :modules, class: Module
        end
      end
    end
  end
end
