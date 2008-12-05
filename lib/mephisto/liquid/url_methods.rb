module Mephisto
  module Liquid
    module UrlMethods
      def self.relative_url_root
        class << self ; attr_reader :relative_url_root ; end
        @relative_url_root = ActionController::Base.relative_url_root || ''
      end
      
      def relative_url_root
        ::Mephisto::Liquid::UrlMethods.relative_url_root
      end

      def absolute_url(*path)
        return "#{relative_url_root}/" if path.empty?
        is_absolute = path.first.to_s[/(^\/)/]
        path.collect! { |p| p.to_s.gsub /(^\/)|(\/$)/, '' }
        path.unshift(is_absolute ? '' : relative_url_root)
        path * '/'
      end
    end
  end
end
