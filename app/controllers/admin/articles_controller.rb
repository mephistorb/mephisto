class Admin::ArticlesController < Admin::BaseController
  with_options :only => [:create, :update] do |c|
    c.before_filter :set_default_section_ids
    c.before_filter :save_or_draft
    c.cache_sweeper :article_sweeper
    c.cache_sweeper :section_sweeper
    cache_sweeper :comment_sweeper, :only => [:approve, :unapprove, :destroy_comment]
  end
  
  before_filter :find_site_article, :only => [:update, :comments, :approve, :unapprove]
  before_filter :load_sections, :only => [:new, :edit, :draft]

  def index
    @drafts        = site.drafts.find_new(:all)
    @article_pages = Paginator.new self, site.articles.count, 30, params[:page]
    @articles      = site.articles.find(:all, :order => 'contents.created_at DESC',
                       :include => [:user, :draft],
                       :limit   =>  @article_pages.items_per_page,
                       :offset  =>  @article_pages.current.offset)
  end

  def show
    @article  = site.articles.find_by_id(params[:id], :include => :comments)
    @comments = @article.comments.collect { |c| c.to_liquid }
    Mephisto::Liquid::CommentForm.article = @article
    @article  = @article.to_liquid(:single)
    render :text => Template.render_liquid_for(site, site.sections.home, :single, 'articles' => [@article], 'article' => @article, 'comments' => @comments, 'site' => site.to_liquid)
  end

  def new
    @article = site.articles.build
  end

  def edit
    @article = site.articles.find(params[:id], :include => :draft)
    @version = params[:version] ? @article.find_version(params[:version]) : @article
  end

  def create
    @article = current_user.articles.create params[:article].merge(
      :updater => current_user, 
      :draft => Article::Draft.find_by_id(params[:draft]),
      :site => site)
      
    if @article.new_record?
      load_sections
      render :action => 'new'
    else
      redirect_to :action => 'index'
    end
  end
  
  def update
    if @article.update_attributes(params[:article].merge(:updater => current_user))
      redirect_to :action => 'index'
    else
      @sections = site.sections
      render :action => 'edit'
    end
  end

  def draft
    @draft   = site.drafts.find(params[:id], :include => :article)
    @article = @draft.to_article
    render :action => (@article.new_record? ? :new : :edit)
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

  def set_akismet
    Akismet.api_key = params[:api_key]
    Akismet.blog    = params[:blog]
    render :update do |page|
      page[:akismet].visual_effect :drop_out
    end
  end

  protected
    def save_or_draft
      if draft?(params[:submit])
        params[:id] ? update_draft : create_draft
        @article.save_draft
        @draft = @article.draft
        flash[:notice] = "Your draft has been created"
        redirect_to :action => 'index'
        return false
      end
    end
    
    def update_draft
      @article = site.articles.find(params[:id])
      @article.attributes = params[:article]
    end
    
    def create_draft
      @article = site.articles.build(params[:article])
      @article.draft = site.drafts.find(params[:draft]) if params[:draft]
    end
    
    def load_sections
      @sections = site.sections.find :all, :order => 'name'
      home = @sections.find { |s| s.name == 'home' }
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
    
    def save_button
      @save_button ||= 'Apply Changes'
    end
    
    def create_button
      @create_button ||= 'Save Article'
    end
    
    def draft_button
      @draft_button ||= 'Save as Draft'
    end
    
    def draft?(value)
      (@draft_options ||= [draft_button, :draft]).include? value
    end
    
    helper_method :save_button, :create_button, :draft_button
end
