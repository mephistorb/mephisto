module Mephisto
  module Liquid
    module UrlMethods
      def self.relative_url_root
        class << self ; attr_reader :relative_url_root ; end
        @relative_url_root = ActionController::AbstractRequest.relative_url_root || ''
      end
      
      def relative_url_root
        ::Mephisto::Liquid::UrlMethods.relative_url_root
      end

      def absolute_url(*path)
        return "#{relative_url_root}/" if path.empty?
        path.collect! { |p| p.to_s.gsub /(^\/)|(\/$)/, '' }
        path.empty? ? "#{relative_url_root}/" : path.unshift(relative_url_root).join('/')
      end
    end
  end
end