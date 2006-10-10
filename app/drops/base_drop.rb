class BaseDrop < Liquid::Drop
  class_inheritable_reader :liquid_attributes
  write_inheritable_attribute :liquid_attributes, [:id]
  attr_reader :source
  delegate :hash, :to => :source
  
  def initialize(source)
    @source = source
    @liquid = liquid_attributes.inject({}) { |h, k| h.update k.to_s => @source.send(k) }
  end
  
  def context=(current_context)
    current_context.registers[:controller].send(:cached_references) << @source if @source && current_context.registers[:controller]
    # @site is set for every drop except SiteDrop, or you get into an infinite loop
    @site   = current_context['site'].source if !is_a?(SiteDrop) && @site.nil? && current_context['site']
    super
  end

  def before_method(method)
    @liquid[method.to_s]
  end

  def eql?(comparison_object)
    self == (comparison_object)
  end
  
  def ==(comparison_object)
    self.source == (comparison_object.is_a?(self.class) ? comparison_object.source : comparison_object)
  end

  # converts an array of records to an array of liquid drops, and assigns the given context to each of them
  def self.liquify(current_context, *records, &block)
    i = -1
    records = 
      records.inject [] do |all, r|
        i+=1
        attrs = (block && block.arity == 1) ? [r] : [r, i]
        all << (block ? block.call(*attrs) : r.to_liquid)
        all.last.context = current_context if all.last.is_a?(Liquid::Drop)
        all
      end
    records.compact!
    records
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
    
    def liquify(*records, &block)
      self.class.liquify(@context, *records, &block)
    end
end