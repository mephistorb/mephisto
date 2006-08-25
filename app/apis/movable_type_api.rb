module MovableTypeStructs
  class TextFilter < ActionWebService::Struct
    member :key,   :string
    member :label, :string
  end
end

class MovableTypeApi < ActionWebService::API::Base
  inflect_names false

  api_method :supportedTextFilters,
    :returns => [[MovableTypeStructs::TextFilter]]
end

class MovableTypeService < XmlRpcService
  web_service_api MovableTypeApi

  def supportedTextFilters
    FilteredColumn.filters.collect { |(key, filter)| MovableTypeStructs::TextFilter.new(:key => key, :label => filter.filter_name) }
  end
end