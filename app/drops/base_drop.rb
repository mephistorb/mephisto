class BaseDrop < Liquid::Drop
  attr_reader :source
  delegate :hash, :to => :source
  
  def initialize(source)
    @source = source
  end
  
  def context=(current_context)
    current_context.registers[:controller].send(:cached_references) << @source if @source && current_context.registers[:controller]
    # @site is set for every drop except SiteDrop, or you get into an infinite loop
    @site   = current_context['site'].source if !is_a?(SiteDrop) && @site.nil? && current_context['site']
    super
  end
  
  def eql?(comparison_object)
    self == (comparison_object)
  end
  
  def ==(comparison_object)
    self.source == (comparison_object.is_a?(self.class) ? comparison_object.source : comparison_object)
  end
  
  protected
    def self.timezone_dates(*attrs)
      attrs.each do |attr_name|
        module_eval <<-end_eval
          def #{attr_name}
            class << self; attr_reader :#{attr_name}; end
            @#{attr_name} = (@source.#{attr_name} ? @site.timezone.utc_to_local(@source.#{attr_name}) : nil)
          end
        end_eval
      end
    end
end