class ArticleObserver < ActiveRecord::Observer
  def before_save(record)
    if (record.is_a?(Article) && record.save_version?) || record.is_a?(Comment)
      @event = Event.new :mode => Event.mode_from(record)
    end
  end

  def after_save(record)
    if @event && record.is_a?(Article)
      @event.update_attributes :title => record.title, :body => record.body, :article => record, :user => record.updater, :site => record.site
    end
  end

  alias after_destroy after_save
end
