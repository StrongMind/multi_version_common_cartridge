module MultiVersionCommonCartridge
  module Resources
    class CanvasTopic < Topic
      attr_accessor :assignment_group_identifierref, :points_possible,
                    :max_attempts, :allowed_attempts, :is_end_of_module_exam, :grading_type, :submission_types,
                    :peer_review_count, :position, :workflow_state, :discussion_type, :type
    end
  end
end