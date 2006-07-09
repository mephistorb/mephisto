module ReferencedPageCachingHelper
  def pagination_remote_links(paginator, options={}, html_options={})
     name   = options[:name]    || ActionController::Pagination::DEFAULT_OPTIONS[:name]
     params = (options[:params] || ActionController::Pagination::DEFAULT_OPTIONS[:params]).clone
     
     pagination_links_each(paginator, options) do |n|
       params[name] = n
       link_to_function n.to_s, "ExceptionLogger.setPage(#{n})"
     end
  end
end