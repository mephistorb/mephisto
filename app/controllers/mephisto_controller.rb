class MephistoController < ApplicationController
  layout 'default'

  def list
    @tag = params[:tags].blank? ?
      Tag.find_by_name('home') :
      Tag.find_by_name(params[:tags].join('/'))

    @article_pages = Paginator.new self, @tag.articles.size, 15, params[:page]
    @articles = @tag.articles.find_by_date(
                  :limit  =>  @article_pages.items_per_page,
                  :offset =>  @article_pages.current.offset).collect { |a| a.attributes }
  end
end
