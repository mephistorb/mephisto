class MephistoController < ApplicationController
  layout 'default'

  def dispatch
    main
  end

  protected
  def main
    @tag = params[:tags].blank? ?
      Tag.find_by_name('home') :
      Tag.find_by_name(params[:tags].join('/'))

    @article_pages = Paginator.new self, @tag.articles.size, 15, params[:page]
    @articles = @tag.articles.find_by_date(
                  :limit  =>  @article_pages.items_per_page,
                  :offset =>  @article_pages.current.offset).collect { |a| a.attributes }
    render_liquid_template_for :main, 'tag' => @tag, 'articles' => @articles
  end

  def render_liquid_template_for(template_type, assigns = {})
    headers["Content-Type"] ||= 'text/html; charset=utf-8'
    templates          = Template.templates_for(template_type)
    preferred_template = Template.find_preferred(template_type, templates)
    layout_template    = templates['layout']
    assigns.merge! 'content_for_layout' => Liquid::Template.parse(preferred_template).render(assigns)
    render :text => Liquid::Template.parse(layout_template).render(assigns)
  end
end
