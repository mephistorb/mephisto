class Time
  def to_delta(delta_type = :day)
    case delta_type
      when :year then self.class.delta(year)
      when :month then self.class.delta(year, month)
      else self.class.delta(year, month, day)
    end
  end
      
  # Borrowed from Typo
  def self.delta(year, month = nil, day = nil)
    # XXX what to do here?  should we use UTC?
    from = Time.mktime(year, month || 1, day || 1)

    to   = from + 1.year
    to   = from + 1.month unless month.blank?    
    to   = from + 1.day   unless day.blank?
    to   = to.tomorrow    unless month.blank? or day
    return [from.midnight, to.midnight]
  end
end
