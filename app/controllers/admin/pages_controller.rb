class Admin::PagesController < Admin::BaseController
  cache_sweeper :category_sweeper
  verify :params => :id, :only => [:edit, :update, :order],
         :add_flash   => { :error => 'Category required' },
         :redirect_to => { :action => 'index' }
  verify :method => :post, :params => :category, :only => :update,
         :add_flash   => { :error => 'Category required' },
         :redirect_to => { :action => 'edit' }
  before_filter :select_category, :except => :index

  def order
    Article.transaction do
      params[:articles].each_with_index do |pos, index|
        @category.categorizations.detect { |t| t.article_id.to_s == pos }.update_attributes(:position => index)
      end
      @category.save # kick off the sweeper!
    end
    render :nothing => true
  end

  def update
    saved = @category.update_attributes(params[:category])
    return if request.xhr?
    if saved
      flash[:notice] = "#{@category.name} updated."
      redirect_to :action => 'edit', :id => @category
    else
      render :action => 'edit'
    end
  end

  protected
  def select_category
    @category = Category.find_paged { Category.find_by_name(params[:id]) }
  end
end
