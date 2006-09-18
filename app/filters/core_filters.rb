module CoreFilters
  def page_title(page)
    page['title']
  end

  def escape_html(html)
    CGI::escapeHTML(html)
  end
  
  alias h escape_html

  def pluralize(count, singular, plural = nil)
    "#{count} " + if count == 1
      singular
    elsif plural
      plural
    elsif Object.const_defined?(:Inflector)
      Inflector.pluralize(singular)
    else
      singular + "s"
    end
  end
  
  # See: http://starbase.trincoll.edu/~crypto/resources/LetFreq.html
  def word_count(text)
    (text.split(/[^a-zA-Z]/).join(' ').size / 4.5).round
  end

  def textilize(text)
    text.blank? ? '' : RedCloth.new(text).to_html
  end

  def format_date(date, format, ordinalized = false)
    return '' if date.nil?
    if ordinalized
      date ? date.to_time.to_ordinalized_s(format.to_sym) : nil
    else
      date ? date.to_time.to_s(format.to_sym) : nil unless ordinalized
    end
  end
  
  def strftime(date, format)
    date ? date.strftime(format) : nil
  end

  def assign_to(value, name)
    @context[name] = value ; nil
  end

  def assign_to_global(value, name)
    @context.assigns.last[name] = value ; nil
  end
end
