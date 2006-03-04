class ArticleObserver < ActiveRecord::Observer
  observe Article, Comment

  def before_save(record)
    @event = Event.new 
    @event.mode = case
      when record.is_a?(Comment)      then 'comment'
      when record.recently_published? then 'publish'
      when record.new_record?         then 'create'
      else 'edit'
    end
  end

  def after_save(record)
    if record.is_a?(Comment)
      @event.update_attributes :title => record.article.title, :body => record.body, :article => record.article,
        :author => record.author, :author_url => record.author_url, :author_email => record.author_email, :author_ip => record.author_ip
    else
      @event.update_attributes :title => record.title, :body => record.body, :user => record.updater, :article => record
    end
  end
end