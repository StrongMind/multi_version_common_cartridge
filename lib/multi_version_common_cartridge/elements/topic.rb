module MultiVersionCommonCartridge
  module Elements
    class Topic
      include SAXMachine

      attribute :xmlns
      attribute 'xmlns:xsi', as: :xmlns_xsi

      element 'topic', as: :topic

    end
  end
end
