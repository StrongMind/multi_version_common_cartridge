module MultiVersionCommonCartridge
  module Elements
    module Canvas
      class TopicMeta
        include SAXMachine

        attribute :xmlns
        attribute 'xmlns:xsi', as: :xmlns_xsi
        attribute :identifier, as: :identifier

        element :topic_id
        element :title

        element :assignment, class: Assignment

        element :position
        element :workflow_state
        element :discussion_type
        element :type
      end

    end
  end
end