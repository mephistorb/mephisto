Mephisto.module_eval do
  def self.convert_from(engine, site_title = nil)
    require "converters/#{engine}"
    site = site_title ? Site.find_by_title(site_title) : Site.find(:first)
    puts "converting #{engine.to_s.humanize}..."
    engine.to_s.camelize.constantize.convert(site)
  end
end