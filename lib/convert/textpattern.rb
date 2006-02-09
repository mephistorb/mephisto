require 'convert/textpattern/article'
require 'convert/textpattern/comment'
module TextPattern
  def self.convert
    tag = Tag.find_by_name('home')
    TextPattern::Article.find(:all, :include => :comments).each do |article|
      a = ::Article.create(:title      => article.Title, 
                         :summary      => article.Excerpt,
                         :description  => article.Body,
                         :created_at   => article.Posted,
                         :published_at => article.Posted,
                         :updated_at   => article.LastMod,
                         :user_id      => 1)
      a.categorizations.create :tag => tag
      article.comments.each do |comment|
        a.comments.create(:description  => comment.message,
                          :created_at   => comment.posted,
                          :updated_at   => comment.posted,
                          :published_at => comment.posted,
                          :author       => comment.name,
                          :author_url   => comment.web,
                          :author_email => comment.email,
                          :author_ip    => comment.ip)
      end
    end
  end
end
