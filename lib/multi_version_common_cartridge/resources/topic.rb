module MultiVersionCommonCartridge
  module Resources
    class Topic < MultiVersionCommonCartridge::Resources::Resource
      attr_accessor :title, :text, :is_canvas
    end
  end
end
