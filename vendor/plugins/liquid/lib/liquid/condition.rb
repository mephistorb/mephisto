module Liquid
  # Container for liquid nodes which conveniently wrapps decision making logic
  #
  # Example:
  #
  #   c = Condition.new('1', '==', '1') 
  #   c.evaluate #=> true
  #
  class Condition
    attr_reader :attachment
    attr_accessor :left, :operator, :right
  
    def initialize(left = nil, operator = nil, right = nil)
      @left, @operator, @right = left, operator, right
    end
    
    def evaluate(context = Context.new)
      interpret_condition(left, right, operator, context)
    end
  
    def attach(attachment)
      @attachment = attachment
    end
  
    def else?
      false
    end
    
    private
  
    def equal_variables(left, right)
      if left.is_a?(Symbol)
        if right.respond_to?(left)
          return right.send(left.to_s) 
        else
          return nil
        end
      end

      if right.is_a?(Symbol)
        if left.respond_to?(right)
          return left.send(right.to_s) 
        else
          return nil
        end
      end

      left == right      
    end    

    def interpret_condition(left, right, op, context)

      # If the operator is empty this means that the decision statement is just 
      # a single variable. We can just poll this variable from the context and 
      # return this as the result.
      return context[left] if op == nil      

      left, right = context[left], context[right]

      operation = case op
      when '==' then return equal_variables(left, right)
      when '!=' then return !equal_variables(left, right)
      when '<>' then return !equal_variables(left, right)
      when '>'  then :>
      when '<'  then :<
      when '>=' then :>=
      when '<=' then :<=
      else
        raise ArgumentError.new("Error in tag '#{name}' - Unknown operator #{op}")        
      end

      if left.respond_to?(operation) and right.respond_to?(operation)
        left.send(operation, right)      
      else
        nil
      end
    end    
  end

  class ElseCondition < Condition
      
    def else? 
      true
    end
  
    def evaluate(context)
      true
    end
  end

end