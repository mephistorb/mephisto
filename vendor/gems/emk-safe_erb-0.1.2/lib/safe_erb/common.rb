# SafeERB

require 'erb'
require 'action_controller'
require 'action_view'

# TODO - RAILS_ROOT is improperly escaped in the standard error template
# that you see in development mode.  We need to fix this in Edge Rails
# if it hasn't been fixed already.  Since it isn't under the control of
# remote users, we're just going to go ahead and untaint it for now.
RAILS_ROOT.untaint if defined?(RAILS_ROOT)

class ActionController::Base
  # Object#taint is set when the request comes from FastCGI or WEBrick,
  # but it is not set in Mongrel and also functional / integration testing
  # so we'll set it anyways in the filter
  before_filter :taint_request
  
  def render_with_taint_logic(*args, &blk)
    if @skip_checking_tainted
      ERB.without_checking_tainted do
        render_without_taint_logic(*args, &blk)
      end
    else
      render_without_taint_logic(*args, &blk)
    end
  end

  alias_method_chain :render, :taint_logic

  private
  
  def taint_hash(hash)
    hash.each do |k, v|
      case v
      when String
        v.taint
      when Hash
        taint_hash(v)
      end
    end
  end
  
  def taint_request
    taint_hash(params)
    cookies.each do |k, v|
      v.taint
    end
  end
end

class String
  def concat_unless_tainted(str)
    raise "attempted to output tainted string: #{str}" if str.is_a?(String) && str.tainted?
    concat(str)
  end
end
