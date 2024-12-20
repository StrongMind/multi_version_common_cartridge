module MultiVersionCommonCartridge
  module Resources
    class CanvasTopic < MultiVersionCommonCartridge::Resources::Resource
      attr_accessor :title, :position, :workflow_state, :discussion_type, :type, :assignment
    end
  end
end