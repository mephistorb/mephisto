module Convert
  def self.from(engine)
    require "convert/#{engine}"
    puts "converting #{engine.to_s.humanize}..."
    engine.to_s.classify.constantize.convert
  end
end