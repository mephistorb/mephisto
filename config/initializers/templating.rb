module Liquid
  AllowedVariableCharacters = /[a-zA-Z_.-]/ unless Liquid.const_defined?(:AllowedVariableCharacters)
end

Liquid::For.send :include, Mephisto::Liquid::ForWithSorting

WhiteListHelper.tags.merge %w(table tr td)

class MissingTemplateError < StandardError
  attr_reader :template_type, :templates
  def initialize(template_type, templates)
    @template_type = template_type
    @templates     = templates
    super "No template found for #{template_type}, checked #{templates.to_sentence}."
  end
end

class MissingThemesError < StandardError
  attr_reader :site
  def initialize(site)
    @site = site
    super "No themes found in '#{site.theme_path.to_s}/#{site.current_theme_path}'.  This must be set correctly in the site settings."
  end
end

class ThemeError < StandardError
  attr_reader :theme
  def initialize(theme, message)
    @theme = theme
    super message
  end
end