class CommentObserver < ArticleObserver
  def self.disabled?
    Thread.current[:comment_observer_disabled]
  end
  
  def disabled=(value)
    Thread.current[:comment_observer_disabled] = value
  end
  
  def after_save(record)
    @event.update_attributes :title => record.article.title, :body => record.body, :site => record.article.site,
      :article => record.article, :author => record.author, :comment => record if record.approved? && !self.class.disabled?
  end

  def after_destroy(record)
    Event.destroy_all ['comment_id = ?', record.id]
  end
end