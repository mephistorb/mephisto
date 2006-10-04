module Liquid
  class Case < Block
    Syntax     = /(#{QuotedFragment})/
    WhenSyntax = /(#{QuotedFragment})/

    def initialize(markup, tokens)
      @blocks = []
      
      if markup =~ Syntax
        @left = $1
      else
        raise SyntaxError.new("Syntax Error in tag 'case' - Valid syntax: case [condition]")
      end

      push_block('case', markup)
      
      super
    end

    def unknown_tag(tag, markup, tokens)
      if ['when', 'else'].include?(tag)
        push_block(tag, markup)
      else
        super
      end
    end

    def render(context)
      @blocks.inject([]) do |output, block|

        if block.else?
           return render_all(block.attachment, context) if output.empty? || output.join !~ /\S/
        else
          
          if block.evaluate(context)
            context.stack do          
              output += render_all(block.attachment, context)
            end          
          end
          
        end
              
        
        output
      end.join
    end
    
    private
    
    def push_block(tag, markup)            
      
      block = if tag == 'else'
        ElseCondition.new
      elsif markup =~ WhenSyntax
        Condition.new(@left, '==', $1)        
      else
        raise SyntaxError.new("Syntax Error in tag 'case' - Valid when condition: when [condition] ")
      end
            
      @blocks.push(block)      
      @nodelist = block.attach(Array.new) 
    end
    
        
  end    
  
  Template.register_tag('case', Case)
end