class MoveAkismetOptionsToSpamEngineOptionsInSites < ActiveRecord::Migration
  def self.up
    Site.find(:all).each do |site|
      site.spam_engine_options = {:akismet_url => site.akismet_url, :akismet_key => site.akismet_key}
      site.save
    end
  end

  def self.down
    Site.update_all("spam_engine_options = NULL")
  end

  class Site < ActiveRecord::Base
    serialize :spam_engine_options, Hash
  end
end
