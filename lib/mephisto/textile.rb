module Mephisto
  class Textile < Liquid::Block
    include Filter
    def render(context)
      @nodelist.collect do |token|
        token.respond_to?(:render) ?
          token.render(context) :
          textilize(token.to_s)
      end
    end
  end
end