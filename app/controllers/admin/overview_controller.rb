class Admin::OverviewController < Admin::BaseController
  session :off, :only => :feed
  before_filter :basic_auth_required, :only => :feed
  caches_page :feed
  
  helper Admin::ArticlesHelper
  
  def index
    @users = User.find(:all, :order => 'updated_at desc')
    @events, @todays_events, @yesterdays_events = [], [], []
    today, yesterday = Time.now.to_date, 1.day.ago.to_date
    @articles = @site.articles.find(:all, :include => :unapproved_comments, :conditions => ['unapproved_comments_contents.id is not null and (unapproved_comments_contents.approved = ? or unapproved_comments_contents.approved is null)', false])
    @articles.sort! { |x,y| y.unapproved_comments.size <=> y.unapproved_comments.size }
    @site.events.find(:all, :order => 'events.created_at DESC', :include => [:article, :user], :limit => 50).each do |event|
      case event.created_at.to_date
        when today     then @todays_events
        when yesterday then @yesterdays_events
        else                @events
      end << event
    end
  end

  def feed
    @events = @site.events.find(:all, :order => 'events.created_at DESC', :include => [:article, :user], :limit => 25)
    render :layout => false
  end
  
  def delete
    @site.events.find(params[:id]).destroy
    render :update do |page|
      page["event-#{params[:id]}"].visual_effect :drop_out
    end
  end
end
