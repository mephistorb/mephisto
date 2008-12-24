class Admin::ArticlesController < Admin::BaseController
  skip_before_filter :login_required
  with_options :only => [:create, :update, :destroy, :upload] do |c|
    c.before_filter :set_default_section_ids
    c.cache_sweeper :article_sweeper, :assigned_section_sweeper
  end

  before_filter :convert_times_to_utc, :only => [:create, :update, :upload]
  before_filter :check_for_new_draft,  :only => [:create, :update, :upload]
  
  before_filter :find_site_article, :only => [:edit, :update, :comments, :approve, :unapprove, :destroy, :attach, :detach]
  before_filter :protect_action, :only => [:approve, :unapprove, :attach, :detach]
  before_filter :login_required, :except => :upload
  before_filter :load_sections, :only => [:new, :edit]

  def index
    @articles = site.articles.paginate(article_options(:order => 'contents.published_at DESC', :select => 'contents.*',
                                                       :page => params[:page], :per_page => params[:per_page]))
    
    @comments = @site.unapproved_comments.count :all, :group => :article, :order => '1 desc'
    @sections = site.sections.find(:all)
  end

  def show
    @article  = site.articles.find(params[:id])
    @comments = @article.comments.collect &:to_liquid
    Mephisto::Liquid::CommentForm.article = @article
    @article  = @article.to_liquid(:mode => :single)
    
    render :text => site.call_render(site.sections.home, :single, 'articles' => [@article], 'article' => @article, 'comments' => @comments, 'site' => site.to_liquid, 'admin?' => true)
  end

  def new
    @article = site.articles.build(:comment_age => site.comment_age, :filter => current_user.filter, :published_at => utc_to_local(Time.now.utc))
  end

  def edit
    @version   = params[:version] ? @article.versions.find(params[:version]) : @article or raise(ActiveRecord::RecordNotFound)
    @published = @version.published?
    @version.published_at = utc_to_local(@version.published_at || Time.now.utc)
  end

  def create
    @article = current_user.articles.create params[:article].merge(:updater => current_user, :site => site)
    
    @article.save!
    flash[:notice] = "Your article was saved"
    redirect_to :action => 'edit', :id => @article.id
  rescue ActiveRecord::RecordInvalid
    load_sections
    render :action => 'new'
  end
  
  def update
    @article.attributes = params[:article].merge(:updater => current_user)
    save_with_revision? ? @article.save! : @article.save_without_revision!
    flash[:notice] = "Your article was updated"
    redirect_to :action => 'edit', :id => params[:id]
  rescue ActiveRecord::RecordInvalid
    load_sections
    render :action => 'edit'
  end

  def destroy
    @article.destroy
    flash[:notice] = "The article: #{@article.title.inspect} was deleted."
    render :update do |page|
      page.redirect_to :action => 'index'
    end
  end

  def comments
    redirect_to article_comments_path(@article)
  end

  def upload
    @asset   = site.assets.build(params[:asset])
    @asset.save!
  rescue ActiveRecord::RecordInvalid
  ensure
    load_sections # do this after the asset has been created
    if params[:id]
      @article = site.articles.find(params[:id])
      return unless login_required
      @article.attributes = params[:article].merge(:updater => current_user)
      render :action => 'edit'
    else
      return unless login_required
      @article = current_user.articles.build params[:article].merge(:updater => current_user, :site => site)
      render :action => 'new'
    end
  end

  def attach
    @asset = site.assets.find(params[:version])
    @article.assets.add @asset
    respond_to {|format| format.js }
  end

  def detach
    @asset = site.assets.find(params[:version])
    @article.assets.remove @asset
    respond_to {|format| format.js }
  end

  def label
    AssignedAsset.update_all ['label = ?', params[:label]], ['article_id = ? and asset_id = ?', params[:id], params[:version]]
    respond_to {|format| format.js }
  end

  protected
    def load_sections
      @assets = site.assets.find(:all, :limit => 15)
      @bucket_assets = []
      session[:bucket].each do |id, values|
        (@bucket_assets ||= []) << site.assets.find(id)
      end unless session[:bucket].blank? 
      
      @sections = site.sections.find(:all)
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
        params[:article].delete_if { |k, v| k.to_s =~ /\A#{:published_at}/ }
        params[:article][:published_at] = local_to_utc(date)
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
          when 'draft'
            @article_options[:conditions] = 'published_at is null'
        end unless params[:q].blank? && params[:filter] != 'draft'
        if section_id > 0
          @article_options[:joins] = "#{@article_options[:joins]} INNER JOIN assigned_sections ON contents.id = assigned_sections.article_id"
          cond = Article.send(:sanitize_sql, ['assigned_sections.section_id = ?', params[:section]])
          @article_options[:conditions] = @article_options[:conditions] ? "(#{@article_options[:conditions]}) AND (#{cond})" : cond
        end
      end
      @article_options.merge options
    end
    
    def allow_member?
      action_name != 'destroy' || (@article && @article.user_id == current_user.id)
    end
end
