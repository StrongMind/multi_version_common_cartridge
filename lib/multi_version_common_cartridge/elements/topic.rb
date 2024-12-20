module MultiVersionCommonCartridge
  module Elements
    class TopicText
      include SAXMachine

      attribute :type

      element :text
    end

    class Topic
      include SAXMachine

      attribute :xmlns
      attribute 'xmlns:xsi', as: :xmlns_xsi

      element 'title', as: :title
      element 'text_', as: :text, class: TopicText

      element 'attachments', class: ::CommonCartridge::Elements::Resources::Attachments::RootAttachment, as: :attachment_root
    end

  end
end
