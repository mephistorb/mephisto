class Theme
  attr_reader :path, :base_path
  
  def initialize(base)
    @base_path = base
    @path      = Pathname.new(@base_path)
  end

  def attachments
    return @attachments unless @attachments.nil?
    @attachments, @templates, @resources = [], [], []
    @attachments.send(:extend, Mephisto::Attachments::AttachmentMethods::InstanceMethods) ; @attachments.theme = self
    [@resources, @templates].each { |a| a.send(:extend, Mephisto::Attachments::AttachmentMethods::BaseMethods); a.theme = self }
    @resources.send(:extend, Mephisto::Attachments::ResourceMethods)
    @templates.send(:extend, Mephisto::Attachments::TemplateMethods)
    Pathname.glob(File.join(base_path, '**/*')).each do |path|
      next unless path.file?
      @attachments << path
      (path.extname == '.liquid' ? @templates : @resources) << path
    end
    @attachments
  end

  [:resources, :templates].each do |attr|
    define_method attr do
      attachments && instance_variable_get("@#{attr}")
    end
  end
end