require 'coderay'
class CodeMacro < FilteredColumn::Macros::Base
  DEFAULT_OPTIONS = {:wrap => :div, :line_numbers => :table, :tab_width => 2, :bold_every => 5, :hint => false, :line_number_start => 1}
  def self.filter(attributes, inner_text = '', text = '')
    # It's a whole lot easier to just set your attributes statically
    # I think for most of us the only option we're gonna change is 'lang'
    # refer to http://rd.cycnus.de/coderay/doc/classes/CodeRay/Encoders/HTML.html for more info
    # use code_highlighter.css to change highlighting
    # don't change, formats code so code_highlighter.css can be used

    lang    = attributes[:lang].blank? ? nil : attributes[:lang].to_sym
    options = DEFAULT_OPTIONS.dup
    # type of line number to print options: :inline, :table, :list, nil [default = :table]
    # you can change the line_numbers default value but you will probably have to change the css too
    options[:line_numbers]      = attributes[:line_numbers].to_sym    unless attributes[:line_numbers].blank?
    # changes tab spacing [default = 2]
    options[:tab_width]         = attributes[:tab_width].to_i         unless attributes[:tab_width].blank?
    # bolds every 'X' line number
    options[:bold_every]        = attributes[:bold_every].to_i        unless attributes[:bold_every].blank?
    # use it if you want to can be :info, :info_long, :debug just debugging info in the tags
    options[:hint]              = attributes[:hint].to_sym            unless attributes[:hint].blank?
    # start with line number
    options[:line_number_start] = attributes[:line_number_start].to_i unless attributes[:line_number_start].blank?

    inner_text = inner_text.gsub(/\A\r?\n/, '').chomp

    begin
      CodeRay.scan(inner_text, lang.to_sym).html(options)
    rescue ArgumentError
      CodeRay.scan(inner_text, lang.to_sym).html(DEFAULT_OPTIONS)
    rescue
      unless lang.blank?
        RAILS_DEFAULT_LOGGER.warn "CodeRay Error: #{$!.message}"
        RAILS_DEFAULT_LOGGER.debug $!.backtrace.join("\n")
      end
      "<pre><code>#{CGI.escapeHTML(inner_text)}</code></pre>"
    end
  end
end

