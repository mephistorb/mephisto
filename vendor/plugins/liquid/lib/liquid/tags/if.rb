module Liquid
  class If < Block
    Syntax = /(#{QuotedFragment})\s*([=!<>]+)?\s*(#{QuotedFragment})?/
    
    def initialize(tag_name, markup, tokens)    
    
      @blocks = []
      
      push_block('if', markup)
      
      super      
    end
    
    def unknown_tag(tag, markup, tokens)
      if ['elsif', 'else'].include?(tag)
        push_block(tag, markup)
      else
        super
      end
    end
    
    def render(context)
      context.stack do
        @blocks.each do |block|
          if block.evaluate(context)            
            return render_all(block.attachment, context)            
          end
        end 
        ''
      end
    end
    
    private
    
    def push_block(tag, markup)            
      
      block = if tag == 'else'
        ElseCondition.new
      elsif markup =~ Syntax
        Condition.new($1, $2, $3)        
      else
        raise SyntaxError.new("Syntax Error in tag '#{tag}' - Valid syntax: #{tag} [condition]") 
      end
            
      @blocks.push(block)      
      @nodelist = block.attach(Array.new) 
    end
    
  end

  Template.register_tag('if', If)
end