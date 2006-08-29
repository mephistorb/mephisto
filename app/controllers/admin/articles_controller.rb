class Admin::ArticlesController < Admin::BaseController
  with_options :only => [:create, :update, :destroy, :upload] do |c|
    c.before_filter :set_default_section_ids
    c.cache_sweeper :article_sweeper, :section_sweeper, :assigned_section_sweeper
    cache_sweeper   :comment_sweeper, :only => [:approve, :unapprove, :destroy_comment]
  end

  observer      :article_observer, :comment_observer
  before_filter :convert_times_to_utc, :only => [:create, :update, :upload]
  before_filter :check_for_new_draft,  :only => [:create, :update, :upload]
  
  before_filter :find_site_article, :only => [:edit, :update, :comments, :approve, :unapprove, :destroy]
  before_filter :load_sections, :only => [:new, :edit]

  def index
    @article_pages = Paginator.new self, site.articles.count(:all, article_options), 30, params[:page]
    @articles      = site.articles.find(:all, article_options(:order => 'contents.published_at DESC', :select => 'contents.*', 
                       :limit   =>  @article_pages.items_per_page,
                       :offset  =>  @article_pages.current.offset))
    @comments = @site.unapproved_comments.count :all, :group => :article, :order => '1 desc'
    @sections = site.sections.find(:all)
  end

  def show
    @article  = site.articles.find(params[:id])
    @comments = @article.comments.collect &:to_liquid
    Mephisto::Liquid::CommentForm.article = @article
    @article  = @article.to_liquid(:mode => :single)
    
    render :text => site.render_liquid_for(site.sections.home, :single, 'articles' => [@article], 'article' => @article, 'comments' => @comments, 'site' => site.to_liquid)
  end

  def new
    @article = site.articles.build(:comment_age => site.comment_age, :filter => current_user.filter, :published_at => utc_to_local(Time.now.utc))
  end

  def edit
    @version   = params[:version] ? @article.find_version(params[:version]) : @article or raise(ActiveRecord::RecordNotFound)
    @published = @version.published?
    @version.published_at = utc_to_local(@version.published_at || Time.now.utc)
  end

  def create
    @article = current_user.articles.create params[:article].merge(:updater => current_user, :site => site)
    
    @article.save!
    redirect_to :action => 'index'
  rescue ActiveRecord::RecordInvalid
    load_sections
    render :action => 'new'
  end
  
  def update
    @article.attributes = params[:article].merge(:updater => current_user)
    save_with_revision? ? @article.save! : @article.save_without_revision!
    redirect_to :action => 'index'
  rescue ActiveRecord::RecordInvalid
    load_sections
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

  def upload
    @asset   = site.assets.build(params[:asset])
    @asset.save!
  rescue ActiveRecord::RecordInvalid
  ensure
    load_sections # do this after the asset has been created
    @article = site.articles.find_by_id(params[:id])
    if @article
      @article.attributes = params[:article].merge(:updater => current_user)
      render :action => 'edit'
    else
      @article = current_user.articles.create params[:article].merge(:updater => current_user, :site => site)
      render :action => 'new'
    end
  end

  protected
    def load_sections
      @assets = site.assets.find(:all, :order => 'created_at desc', :limit => 6)
      @sections = site.sections.find :all, :order => 'name'
      home = @sections.find &:home?
      @sections.delete  home
      @sections.unshift home if home
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
      params[:article][:published_at] = nil if params[:draft] == '1'
      true
    end
    
    def convert_times_to_utc
      with_site_timezone do
        date = Time.parse_from_attributes(params[:article], :published_at, :local)
        next unless date
        params[:article].delete_if { |k, v| k.to_s =~ /^#{:published_at}/ }
        params[:article][:published_at] = date.utc
      end
    end
    
    def save_with_revision?
      params[:commit].to_s !~ /save without revision/i
    end
    
    def article_options(options = {})
      if @article_options.nil?
        @article_options = {}
        section_id       = params[:section].to_i
        case params[:filter]
          when 'title'
            @article_options[:conditions] = Article.send(:sanitize_sql, ["LOWER(contents.title) LIKE ?", "%#{params[:q].downcase}%"])
          when 'body'
            @article_options[:conditions] = Article.send(:sanitize_sql, ["LOWER(contents.excerpt) LIKE :q OR LOWER(contents.body) LIKE :q", {:q => "%#{params[:q].downcase}%"}])
          when 'tags'
            @article_options[:joins] = "INNER JOIN taggings ON taggings.taggable_id = contents.id and taggings.taggable_type = 'Content' INNER JOIN tags on taggings.tag_id = tags.id"
            @article_options[:conditions] = Article.send(:sanitize_sql, ["tags.name IN (?)", Tag.parse(params[:q])])
        end unless params[:q].blank?
        if section_id > 0
          @article_options[:joins] = "#{@article_options[:joins]} INNER JOIN assigned_sections ON contents.id = assigned_sections.article_id"
          cond = Article.send(:sanitize_sql, ['assigned_sections.section_id = ?', params[:section]])
          @article_options[:conditions] = @article_options[:conditions] ? "(#{@article_options[:conditions]}) AND (#{cond})" : cond
        end
      end
      @article_options.merge options
    end
end
