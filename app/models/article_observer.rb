class ArticleObserver < ActiveRecord::Observer
  def before_save(article)
    @event = Event.new 
    @event.mode = case
      when article.recently_published? then 'publish'
      when article.new_record?         then 'create'
      else 'edit'
    end
  end

  def after_save(article)
    @event.update_attributes :title => article.title, :body => article.body, :user => article.updater, :article => article
  end
end