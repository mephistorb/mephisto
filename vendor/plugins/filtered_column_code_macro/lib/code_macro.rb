require 'coderay'
class CodeMacro < FilteredColumn::Macros::Base
  def self.filter(attributes, inner_text = '', text = '')
    line_numbers = attributes[:linenumbers] ? attributes[:linenumbers].to_sym : :table
    RAILS_DEFAULT_LOGGER.info "LINE NUMBERS: #{line_numbers}"
    options = { :css => :class }.merge({:line_numbers => line_numbers })
    begin
      CodeRay.scan(inner_text, attributes[:lang].to_sym).div(options)
    rescue
      unless attributes[:lang].blank?
        logger.warn "CodeRay Error: #{$!.message}"
        logger.debug $!.backtrace.join("\n")
      end
      "<pre><code>#{inner_text}</code></pre>"
    end
  end
end