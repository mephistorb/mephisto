module Mephisto
  class Dispatcher
    @@year_regex     = /^\d{4}$/
    @@month_regex    = /^\d{1,2}$/

    def self.run(site, path)
      if options = recognize_permalink(site, path)
        if options[1] && options[2]
          return [:comment, nil, options.first, options.last]
        elsif options[1]
          return [:comments, nil, options.first]
        else
          return [:single, nil, options.first]
        end
      end
      
      dispatch_type = :list
      section       = nil
      returning [] do |result|
        # check for tags
        return [:tags, nil] + path[1..-1] if path.first == site.tag_slug
        
        # check for search
        if path.first == site.search_slug
          return (path.size == 1) ? [:search, nil] : [:error, nil]
        end
        
        # look for the section in the path
        while section.nil? && path.any?
          section = site.sections.detect { |s| s.path == path.join('/') }
          result << path.pop if section.nil?
        end
        section ||= site.sections.home
        result.reverse!
        
        # check for archives
        if result[0] == site.archive_slug
          # only allow /archives, /archives/yyyy and /archives/yyyy/mm
          if (result.size < 4 && year?(result[1]) && month?(result[2]))
            dispatch_type = :archives
            result.shift
          else
            dispatch_type = :error
          end
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
    
    def self.recognize_permalink(site, path)
      full_path = path.join('/')
      if match = site.permalink_regex.match(full_path)
        returning([{}]) do |result|
          site.permalink_variables.each_with_index do |var, i|
            result.first[var] = match[i+1]
          end
          result << !match[site.permalink_variables.size + 1].nil?
          result <<  match[site.permalink_variables.size + 3]
        end
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