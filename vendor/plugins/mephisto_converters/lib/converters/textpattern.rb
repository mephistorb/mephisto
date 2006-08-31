require 'converters/textpattern/article'
require 'converters/textpattern/comment'
module TextPattern
  def self.convert
    section = Section.find_by_path('home')
    TextPattern::Article.find(:all, :include => :comments).each do |article|
      a = ::Article.create \
        :title        => article.Title, 
        :excerpt      => article.Excerpt,
        :body         => article.Body,
        :created_at   => article.Posted,
        :published_at => article.Posted,
        :updated_at   => article.LastMod,
        :user_id      => 1

      a.assigned_sections.create :section => section

      article.comments.each do |comment|
        a.comments.create \
          :body         => comment.message,
          :created_at   => comment.posted,
          :updated_at   => comment.posted,
          :published_at => comment.posted,
          :author       => comment.name,
          :author_url   => comment.web,
          :author_email => comment.email,
          :author_ip    => comment.ip
      end
    end
  end
end
