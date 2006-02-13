class UnderscoresToDashes < ActiveRecord::Migration
  def self.up
    Article.transaction do
      Article.find(:all).each { |a| a.permalink.gsub! /_/, '-' ; a.save! }
    end
  end

  def self.down
    Article.transaction do
      Article.find(:all).each { |a| a.permalink.gsub! /-/, '_' ; a.save! }
    end
  end
end
