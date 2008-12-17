require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class SafeERBTest < Test::Unit::TestCase
  def test_non_checking
    ERB.without_checking_tainted do
      src = ERB.new("<%= File.open('#{__FILE__}'){|f| f.read} %>", nil, '-').src
      eval(src)
    end
  end
  
  def test_checking
    src = ERB.new("<%= File.open('#{__FILE__}'){|f| f.read} %>", nil, '-').src
    assert_raise(RuntimeError) { eval(src) }
  end
  
  def test_checking_non_tainted
    src = ERB.new("<%= 'This string is not tainted' %>", nil, '-').src
    eval(src)
  end
end
