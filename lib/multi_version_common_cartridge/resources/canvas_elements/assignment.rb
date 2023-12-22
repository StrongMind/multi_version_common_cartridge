module CanvasCartridge
  module Elements
    module Resources
      module CanvasAssignment

        class Assignment
          include SAXMachine

          attribute :xmlns
          attribute 'xmlns:xsi', as: :xmlns_xsi
          attribute :identifier, as: :identifier

          element 'title', as: :title
          element 'assignment_group_identifierref', as: :assignment_group_identifierref
          element 'points_possible', as: :points_possible
          element 'max_attempts', as: :max_attempts
          element 'allowed_attempts', as: :allowed_attempts
          element 'is_end_of_module_exam', as: :is_end_of_module_exam
          element 'grading_type', as: :grading_type
          element 'submission_types', as: :submission_types
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
