module Liquid
  class Capture < Block
    Syntax = /(\w+)/

    def initialize(tag_name, markup, tokens)      
      if markup =~ Syntax
        @to = $1
      else
        raise SyntaxError.new("Syntax Error in 'capture' - Valid syntax: capture [var]")
      end
      
      super       
    end

    def render(context)
      output = super
      context[@to] = output.to_s
      ''
    end
  end  
  
  Template.register_tag('capture', Capture)
end