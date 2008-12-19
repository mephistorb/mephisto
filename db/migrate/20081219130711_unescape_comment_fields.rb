# We were storing these fields in the database "pre-escaped", which (oddly
# enough) actually increased the number of security problems in our
# application, because we didn't escape the fields until after the record
# was validated, so error pages tended to vulnerable to XSS attacks.  So
# let's just rely on SafeERB and our CommentDrop to make sure we escape on
# output.
class UnescapeCommentFields < ActiveRecord::Migration
  class Content < ActiveRecord::Base
  end

  class Comment < Content
  end

  # Taken from the old sanitize_attributes method in Content.
  ATTRIBUTES =
    [:author, :author_url, :author_email, :author_ip, :user_agent, :referrer]

  def self.up
    Comment.find(:all).each do |c|
      ATTRIBUTES.each do |a|
        c.send("#{a}=", CGI::unescapeHTML(c.send(a).to_s)) if c.send(a)
      end
      c.save!
    end
  end

  def self.down
    Comment.find(:all).each do |c|
      ATTRIBUTES.each do |a|
        c.send("#{a}=", CGI::escapeHTML(c.send(a).to_s)) if c.send(a)
      end
      c.save!
    end
  end
end
