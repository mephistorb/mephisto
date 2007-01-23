require File.dirname(__FILE__) + '/helper'

class ConditionTest < Test::Unit::TestCase
  include Liquid

  def test_default_operators_evalute_true
    assert_evalutes_true '1', '==', '1'
    assert_evalutes_true '1', '!=', '2'
    assert_evalutes_true '1', '<>', '2'
    assert_evalutes_true '1', '<', '2'
    assert_evalutes_true '2', '>', '1'
    assert_evalutes_true '1', '>=', '1'
    assert_evalutes_true '2', '>=', '1'
    assert_evalutes_true '1', '<=', '2'
    assert_evalutes_true '1', '<=', '1'
  end

  def test_default_operators_evalute_false
    assert_evalutes_false '1', '==', '2'
    assert_evalutes_false '1', '!=', '1'
    assert_evalutes_false '1', '<>', '1'
    assert_evalutes_false '1', '<', '0'
    assert_evalutes_false '2', '>', '4'
    assert_evalutes_false '1', '>=', '3'
    assert_evalutes_false '2', '>=', '4'
    assert_evalutes_false '1', '<=', '0'
    assert_evalutes_false '1', '<=', '0'
  end

  def test_should_allow_custom_symbol_operator
    Condition.operators['contains'] = :[]
    
    assert_evalutes_true "'bob'", 'contains', "'o'"
    assert_evalutes_false "'bob'", 'contains', "'f'"
  ensure
    Condition.operators.delete 'contains'
  end

  def test_should_allow_custom_proc_operator
    Condition.operators['starts_with'] = Proc.new { |cond, left, right| left =~ %r{^#{right}}}
    
    assert_evalutes_true "'bob'", 'starts_with', "'b'"
    assert_evalutes_false "'bob'", 'starts_with', "'o'"
  ensure
    Condition.operators.delete 'starts_with'
  end

  private
    def assert_evalutes_true(left, op, right)
      assert Condition.new(left, op, right).evaluate, "Evaluated false: #{left} #{op} #{right}"
    end
    
    def assert_evalutes_false(left, op, right)
      assert !Condition.new(left, op, right).evaluate, "Evaluated true: #{left} #{op} #{right}"
    end
end