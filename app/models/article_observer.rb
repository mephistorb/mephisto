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
    params = { :title => record.title, :body => record.body }
    params.update record.is_a?(Comment) ? { :article => record.article } : { :article => record, :user => record.updater }
    @event.update_attributes params
  end
end