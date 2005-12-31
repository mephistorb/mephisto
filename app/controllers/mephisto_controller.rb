class MephistoController < ApplicationController
  layout 'default'

  def dispatch
    if params[:tags].blank?
      @tag = Tag.find_by_name('home')
      template_type = :main
    else
      @tag = Tag.find_by_name(params[:tags].join('/'))
      template_type = :tag
    end

    @article_pages = Paginator.new self, @tag.articles.size, 15, params[:page]
    @articles = @tag.articles.find_by_date(
                  :limit  =>  @article_pages.items_per_page,
                  :offset =>  @article_pages.current.offset).collect { |a| a.attributes }

    render_liquid_template_for(template_type, 'tag' => @tag, 'articles' => @articles)
  end

  protected
  def render_liquid_template_for(template_type, assigns = {})
    headers["Content-Type"] ||= 'text/html; charset=utf-8'
    templates          = Template.templates_for(template_type)
    preferred_template = Template.find_preferred(template_type, templates)
    layout_template    = templates['layout']
    assigns.merge! 'content_for_layout' => Liquid::Template.parse(preferred_template).render(assigns)
    render :text => Liquid::Template.parse(layout_template).render(assigns)
  end
end
