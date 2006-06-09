module Convert
  def self.from(engine, site_title = nil)
    require "convert/#{engine}"
    if site_title
      site = Site.find_by_title(site_title)
    else
      site = Site.find(:first)
    end
    puts "converting #{engine.to_s.humanize}..."
    engine.to_s.classify.constantize.convert(site)
  end
end