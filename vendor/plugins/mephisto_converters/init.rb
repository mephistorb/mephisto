module Convert
  def self.from(engine, site_title = nil)
    require "convert/#{engine}"
    site = site_title ? Site.find_by_title(site_title) : Site.find(:first)
    puts "converting #{engine.to_s.humanize}..."
    engine.to_s.classify.constantize.convert(site)
  end
end