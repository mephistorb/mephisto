class AssetDrop < BaseDrop
  liquid_attributes.push(*[:content_type, :size, :filename, :width, :height])
  def asset() @source end

  [:image, :movie, :audio, :other, :pdf].each do |content|
    define_method("is_#{content}") { @source.send("#{content}?") }
  end
  
  def tags
    @tags ||= liquidize *@source.tags
  end

  def path
    @path = @source.public_filename
  end
end
