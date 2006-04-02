module Liquid
  
  class Tag
    attr_accessor :nodelist
    
    def initialize(markup, tokens)
      @markup = markup
      parse(tokens)
    end
    
    def parse(tokens)
    end
    
    def render(context)
      ''
    end    
  end
   

end
   