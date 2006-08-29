require 'coderay'
class CodeMacro < FilteredColumn::Macros::Base
  def self.filter(attributes, inner_text = '', text = '')
    lang = attributes.delete(:lang)
    attributes[:line_numbers] = :table unless attributes.has_key?(:line_numbers)
    attributes.each do |key, value|
      attributes[key] = value == 'nil' ? nil : value.to_sym rescue nil
    end

    begin
      CodeRay.scan(inner_text, lang.to_sym).html(attributes)
    rescue ArgumentError
      CodeRay.scan(inner_text, lang.to_sym).html(:line_numbers => :table)
    rescue
      unless lang.blank?
        RAILS_DEFAULT_LOGGER.warn "CodeRay Error: #{$!.message}"
        RAILS_DEFAULT_LOGGER.debug $!.backtrace.join("\n")
      end
      "<pre><code>#{inner_text}</code></pre>"
    end
  end
end

