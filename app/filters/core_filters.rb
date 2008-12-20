module CoreFilters
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

  def parse_date(date)
    return Time.now.utc if date.blank?
    date = "#{date}-1" if date.to_s =~ /\A\d{4}-\d{1,2}\z/ unless [Time, Date].include?(date.class)
    date = date.to_time
  end

  def format_date(date, format, ordinalized = false)
    return '' if date.nil?
    if ordinalized
      date ? parse_date(date).to_ordinalized_s(format.to_sym) : nil
    else
      date ? parse_date(date).to_s(format.to_sym) : nil unless ordinalized
    end
  end
  
  def strftime(date, format)
    date ? date.strftime(format) : nil
  end

  def index(array, index = 0)
    array[index] if array.respond_to?(:[])
  end

  def assign_to(value, name)
    @context[name] = value ; nil
  end

  def assign_to_global(value, name)
    @context.scopes.last[name] = value ; nil
  end
  
  def contains(source, text)  
    !source[text].nil?
  end

  protected
    def liquify(*records, &block)
      BaseDrop.liquify(@context, *records, &block)
    end
end
