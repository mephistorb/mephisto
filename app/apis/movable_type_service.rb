class MovableTypeService < XmlRpcService
  web_service_api MovableTypeApi

  def supportedTextFilters
    FilteredColumn.filters.collect { |(key, filter)| MovableTypeStructs::TextFilter.new(:key => key, :label => filter.filter_name) }
  end
end