class Admin::PagesController < Admin::BaseController
  cache_sweeper :tag_sweeper
  verify :params => :id, :only => [:edit, :update, :order],
         :add_flash   => { :error => 'Tag required' },
         :redirect_to => { :action => 'index' }
  verify :method => :post, :params => :tag, :only => :update,
         :add_flash   => { :error => 'Tag required' },
         :redirect_to => { :action => 'edit' }
  before_filter :select_tag, :except => :index

  def order
    Article.transaction do
      params[:articles].each_with_index do |pos, index|
        @tag.taggings.detect { |t| t.article_id.to_s == pos }.update_attributes(:position => index)
      end
      @tag.save # kick off the sweeper!
    end
    render :nothing => true
  end

  def update
    saved = @tag.update_attributes(params[:tag])
    return if request.xhr?
    if saved
      flash[:notice] = "#{@tag.name} updated."
      redirect_to :action => 'edit', :id => @tag
    else
      render :action => 'edit'
    end
  end

  protected
  def select_tag
    @tag = Tag.find_paged { Tag.find_by_name(params[:id]) }
  end
end
