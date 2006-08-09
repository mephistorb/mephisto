module Mephisto
  module Liquid
    class Textile < ::Liquid::Block
      include Filters
      def render(context)
        @nodelist.collect do |token|
          token.respond_to?(:render) ?
            token.render(context) :
            textilize(token.to_s)
        end
      end
    end
  end
end