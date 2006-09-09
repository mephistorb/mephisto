class MovableTypeApi < ActionWebService::API::Base
  inflect_names false

  api_method :supportedTextFilters,
    :returns => [[MovableTypeStructs::TextFilter]]
end