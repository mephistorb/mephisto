class ArticleObserver < ActiveRecord::Observer
  def before_save(record)
    @event = Event.new 
    @event.mode = case
      when record.is_a?(Comment) then 'comment'
      when record.new_record?    then 'publish'
      else 'edit'
    end
  end

  def after_save(record)
    if @event && record.is_a?(Article)
      @event.update_attributes :title => record.title, :body => record.body, :article => record, :user => record.updater, :site => record.site
    end
  end

  alias after_destroy after_save
end