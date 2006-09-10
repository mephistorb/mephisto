module Mephisto
  class Dispatcher
    @@tag_slug     = 'tags'
    @@archive_slug = 'archives'
    @@year_regex   = /^\d{4}$/
    @@month_regex  = /^\d{1,2}$/

    def self.run(site, path)
      dispatch_type = :list
      section       = nil
      returning [] do |result|
        # check for tags
        return [:tags, nil] + path[1..-1] if path.first == @@tag_slug
        
        # look for the section in the path
        while section.nil? && path.any?
          section = site.sections.detect { |s| s.path == path.join('/') }
          result << path.pop if section.nil?
        end
        section ||= site.sections.home
        result.reverse!
        
        # check for archives
        if result[0] == @@archive_slug
          # only allow /archives, /archives/yyyy and /archives/yyyy/mm
          dispatch_type = (result.size < 4 && year?(result[1]) && month?(result[2])) ? :archives : :error
        end
        
        # check for pages
        dispatch_type = :page if dispatch_type == :list && section.show_paged_articles?
        
        # check for invalid section or paged attributes
        if (dispatch_type == :page && result.size > 1) || (dispatch_type == :list && result.any?)
          dispatch_type = :error
        end
        
        #result.size > (result[0] == :page ? )
        result.unshift section
        result.unshift dispatch_type
      end
    end
    
    private
      def self.year?(n)
        n.nil? || n =~ @@year_regex
      end
      
      def self.month?(n)
        n.nil? || n =~ @@month_regex
      end
  end
end