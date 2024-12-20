module MultiVersionCommonCartridge
  module Elements
    class Topic
      include SAXMachine

      attribute :xmlns
      attribute 'xmlns:xsi', as: :xmlns_xsi

      element 'title', as: :title
      element 'text', as: :topic_text

    end
  end
end
