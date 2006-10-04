class AssetDrop < BaseDrop
  def asset() @source end

  def initialize(source)
    @source = source
    super source
    @site_liquid = [:id, :content_type, :size, :filename, :width, :height].inject({}) { |h, k| h.merge k.to_s => @source.send(k) }
  end

  def before_method(method)
    @site_liquid[method.to_s]
  end

  [:image, :movie, :audio, :other, :pdf].each do |content|
    define_method("is_#{content}") { @source.send("#{content}?") }
  end
  
  def tags
    @tags ||= @source.tags.collect &:name
  end

  def path
    @path = @source.public_filename
  end
end
