class Admin::ArticlesController < Admin::BaseController
  with_options :only => [:create, :update, :destroy] do |c|
    c.before_filter :set_default_section_ids
    c.cache_sweeper :article_sweeper, :section_sweeper, :assigned_section_sweeper
    cache_sweeper   :comment_sweeper, :only => [:approve, :unapprove, :destroy_comment]
  end

  observer      :article_observer, :comment_observer
  before_filter :check_for_new_draft,  :only => [:create, :update]
  before_filter :convert_times_to_utc, :only => [:create, :update]
  
  before_filter :find_site_article, :only => [:edit, :update, :comments, :approve, :unapprove, :destroy]
  before_filter :load_sections, :only => [:new, :edit]

  def index
    @article_pages = Paginator.new self, site.articles.count, 30, params[:page]
    @articles      = site.articles.find(:all, :order => 'contents.created_at DESC', :include => :user,
                       :limit   =>  @article_pages.items_per_page,
                       :offset  =>  @article_pages.current.offset)
  end

  def show
    @article  = site.articles.find(params[:id])
    @comments = @article.comments.collect &:to_liquid
    Mephisto::Liquid::CommentForm.article = @article
    @article  = @article.to_liquid(:single)
    render :text => Template.render_liquid_for(site, site.sections.home, :single, 'articles' => [@article], 'article' => @article, 'comments' => @comments, 'site' => site.to_liquid)
  end

  def new
    @article = site.articles.build(:filters => current_user.filters, :parse_macros => current_user.parse_macros, :published_at => utc_to_local(Time.now.utc))
  end

  def edit
    @version   = params[:version] ? @article.find_version(params[:version]) : @article
    @published = @version.published?
    [:published_at, :expire_comments_at].each do |attr|
      @version.send("#{attr}=", utc_to_local(@version.send(attr) || Time.now.utc))
    end
  end

  def create
    @article = current_user.articles.create params[:article].merge(:updater => current_user, :site => site)
      
    if @article.new_record?
      load_sections
      render :action => 'new'
    else
      redirect_to :action => 'index'
    end
  end
  
  def update
    @article.attributes = params[:article].merge(:updater => current_user)
    save_with_revision? ? @article.save! : @article.save_without_revision!
    redirect_to :action => 'index'
  rescue ActiveRecord::RecordInvalid
    @sections = site.sections
    render :action => 'edit'
  end

  def destroy
    @article.destroy
    render :update do |page|
      page.redirect_to :action => 'index'
    end
  end

  def comments
    @comments = 
      case params[:filter]
        when 'approved'   then :comments
        when 'unapproved' then :unapproved_comments
        else                   :all_comments
      end
    @comments = @article.send @comments
  end

  # xhr baby
  # needs some restful lovin'
  def approve
    @comment = @article.unapproved_comments.approve(params[:comment])
  end

  def unapprove
    @comment = @article.comments.unapprove(params[:comment])
    render :action => 'approve'
  end
  
  def destroy_comment
    @comments = site.all_comments.find :all, :conditions => ['id in (?)', [params[:comment]].flatten] rescue []
    Comment.transaction { @comments.each(&:destroy) } if @comments.any?
  end

  protected
    def load_sections
      @sections = site.sections.find :all, :order => 'name'
      home = @sections.find &:home?
      @sections.delete  home
      @sections.unshift home
    end

    def find_site_article
      @article = site.articles.find(params[:id])
    end

    def set_default_section_ids
      params[:article] ||= {}
      params[:article][:section_ids] ||= []
    end
    
    def check_for_new_draft
      params[:article] ||= {}
      [:published_at, :expire_comments_at].each { |k| params[:article][k] = nil } unless params[:draft].blank?
    end
    
    def convert_times_to_utc
      with_site_timezone do
        [:published_at, :expire_comments_at].each do |attr|
          date = Time.parse_from_attributes(params[:article], attr, :local)
          next unless date
          params[:article].delete_if { |k, v| k.to_s =~ /^#{attr}/ }
          params[:article][attr] = date.utc
        end
      end
    end
    
    def save_with_revision?
      params[:commit].to_s !~ /save without revision/i
    end
end
