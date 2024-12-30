module MultiVersionCommonCartridge
  module Resources
    class Topic < MultiVersionCommonCartridge::Resources::Resource
      attr_accessor :title, :text, :canvas_topic

      def dependencies
        [canvas_topic]
      end
    end
  end
end
