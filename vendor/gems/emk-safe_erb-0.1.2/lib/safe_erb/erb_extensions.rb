class ERB
  # Should we check for tainted values when building ERB templates?
  def self.check_tainted?
    value = Thread.current[:safe_erb_check_tainted]
    value.nil? ? false : value
  end

  # Turn ERB taint-checking on and off.
  def self.check_tainted= value
    Thread.current[:safe_erb_check_tainted] = value
  end

  # Enable taint checks within the specified block.
  def self.with_checking_tainted #:yield:
    saved_value = ERB.check_tainted?
    ERB.check_tainted = true
    begin
      yield
    ensure
      ERB.check_tainted = saved_value
    end
  end

  # Skip taint checks within the specified block.
  def self.without_checking_tainted #:yield:
    saved_value = ERB.check_tainted?
    ERB.check_tainted = false
    begin
      yield
    ensure
      ERB.check_tainted = saved_value
    end
  end
  
  alias_method :original_set_eoutvar, :set_eoutvar
  
  def set_eoutvar(compiler, eoutvar = '_erbout')
    original_set_eoutvar(compiler, eoutvar)
    if ERB.check_tainted?
      if compiler.respond_to?(:insert_cmd)
        compiler.insert_cmd = "#{eoutvar}.concat_unless_tainted"
      else
        compiler.put_cmd = "#{eoutvar}.concat_unless_tainted"
      end
    end
  end
  
  module Util
    alias_method :html_escape_without_untaint, :html_escape
    
    def html_escape(s)
      h = html_escape_without_untaint(s)
      h.untaint
      h
    end
    
    alias_method :h, :html_escape
    
    module_function :h
    module_function :html_escape
    module_function :html_escape_without_untaint
  end
end
