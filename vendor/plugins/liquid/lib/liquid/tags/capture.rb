module Liquid
  class Capture < Block
    Syntax = /(\w+)/

    def initialize(markup, tokens)
      if markup =~ Syntax
        @to = $1
        super 
      else
        raise SyntaxError.new("Syntax Error in 'capture' - Valid syntax: capture [var]")
      end
    end

    def render(context)
      output = super
      context[@to] = output.to_s
      ''
    end
  end  
  
  Template.register_tag('capture', Capture)
end