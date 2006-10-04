class BaseDrop < Liquid::Drop
  attr_reader :source
  delegate :hash, :to => :source
  
  def initialize(source)
    @source = source
  end
  
  def context=(current_context)
    current_context.registers[:controller].send(:cached_references) << @source if @source
    super
  end
  
  def eql?(comparison_object)
    self == (comparison_object)
  end
  
  def ==(comparison_object)
    self.source == (comparison_object.is_a?(self.class) ? comparison_object.source : comparison_object)
  end
end