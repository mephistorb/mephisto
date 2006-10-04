module Liquid
  class Assign < Tag
    Syntax = /(\w+)\s*=\s*(#{QuotedFragment}+)/   
  
    def initialize(markup, tokens)
      if markup =~ Syntax
        @to = $1
        @from = $2
      else
        raise SyntaxError.new("Syntax Error in 'assign' - Valid syntax: assign [var] = [source]")
      end
    end
  
    def render(context)
       context[@to] = context[@from]
       ''       
    end 
  
  end  
  
  Template.register_tag('assign', Assign)  
end