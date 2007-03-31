class FilterCurrentComments < ActiveRecord::Migration
  def self.up
    transaction do
      Comment.find(:all).each do |c|
        Comment.update_all ['author = ?, author_url = ?, author_email = ?, author_ip = ?, user_agent = ?, referrer = ?', 
          CGI::escapeHTML(c.author), CGI::escapeHTML(c.author_url), CGI::escapeHTML(c.author_email), CGI::escapeHTML(c.author_ip),
          CGI::escapeHTML(c.user_agent), CGI::escapeHTML(c.referrer)], ['id = ?', c.id]
      end
    end
  end

  def self.down
  end
end
