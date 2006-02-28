module Admin::UsersHelper
  def filter_options
    [['Plain HTML', ''], ['Textile', 'textile_filter'], ['Markdown', 'markdown_filter'], ['Markdown with Smarty Pants', 'smartypants']]
  end
end
