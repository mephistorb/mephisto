require 'coderay'
class CodeMacro < FilteredColumn::Macros::Base
  def self.filter(attributes, inner_text = '', text = '')
    options = { :line_numbers => attributes[:linenumbers].to_sym, :css => :class }
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