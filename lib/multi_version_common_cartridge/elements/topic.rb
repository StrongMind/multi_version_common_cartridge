module MultiVersionCommonCartridge
  module Elements
    class Topic
      include SAXMachine

      attribute :xmlns
      attribute 'xmlns:xsi', as: :xmlns_xsi

      element 'title', as: :title
      element 'text_', as: :text

    end
  end
end
