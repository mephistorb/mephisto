module Mephisto
  @@liquid_filters = [CoreFilters, DropFilters, UrlFilters]
  @@liquid_tags    = {:textile => Mephisto::Liquid::Textile, :commentform => Mephisto::Liquid::CommentForm, :head => Mephisto::Liquid::Head}
  mattr_reader :liquid_tags, :liquid_filters
end