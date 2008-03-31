module Mephisto
  class Dispatcher
    PERMALINK_OPTIONS = { :year => '\d{4}', :month => '\d{1,2}', :day => '\d{1,2}', :permalink => '[\w\-]+', :id => '\d+' }
    PERMALINK_VAR     = /^:([a-z]+)$/

    def self.run(site, path)
      # check for any bad urls like /foo//bar
      return [:error, nil, *path] if path.any? &:blank?
      
      if args = Mephisto::Routing.handle_redirection(path * "/")
        return [:redirect, *args]
      end

      # check for permalink
      if options = recognize_permalink(site, path)
        if options[1] == 'comments' && options[2]
          return [:comment, nil, options.first, options.last]
        elsif options[1] == 'comments'
          return [:comments, nil, options.first]
        elsif options[1] == 'comments.xml'
          return [:comments_feed, nil, options.first]
        elsif options[1] == 'changes.xml'
          return [:changes_feed, nil, options.first]
        else
          return [:single, nil, options.first]
        end
      end

      # check for tags
      return [:tags, nil] + path[1..-1] if path.first == site.tag_path
      
      # check for search
      if path.first == site.search_path
        return (path.size == 1) ? [:search, nil] : [:error, nil]
      end

      dispatch_type = :list
      section       = nil
      returning [] do |result|
        # look for the section in the path
        while section.nil? && path.any?
          section = site.sections.detect { |s| s.path == path.join('/') }
          result << path.pop if section.nil?
        end
        section ||= site.sections.home
        result.reverse!
        
        # check for archives
        if result[0] == section.archive_path
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
    
    # returns an array with 3 values: [article_params, suffix, comment_id]
    def self.recognize_permalink(site, path)
      full_path = path.join('/')
      regex, variables = build_permalink_regex_with(site.permalink_style)
      if match = regex.match(full_path)
        returning([{}]) do |result|
          variables.each_with_index do |var, i|
            result.first[var] = match[i+1]
          end
          result << match[variables.size + 2] # comments | comments.xml | changes.xml
          result.last.gsub!(/\/(.*)$/, '') if result.last
          result << match[variables.size + 4] # comment id
        end
      end
    end

    def self.build_permalink_regex_with(permalink_style)
      variables = []
      regex = permalink_style.split('/').inject [] do |s, piece|
        if name = variable_format?(piece)
          variables << name.to_sym
          s << "(#{PERMALINK_OPTIONS[variables.last]})"
        else
          s << piece
        end
      end

      [Regexp.new("^#{regex.join('\/')}(\/(comments(\/(\\d+))?|comments\.xml|changes\.xml))?$"), variables]
    end

    def self.variable_format?(var)
      var =~ PERMALINK_VAR ? $1 : nil
    end

    def self.variable?(var)
      (name = variable_format?(var)) && PERMALINK_OPTIONS.keys.include?(name.to_sym) rescue nil
    end

    def self.build_permalink_with(permalink_style, article)
      old_published          = article.published_at
      article.published_at ||= Time.now.utc
      article.article_id   ||= article.id
      '/' + permalink_style.split('/').collect! do |piece|
        (name = variable_format?(piece)) && PERMALINK_OPTIONS.keys.include?(name.to_sym) ? variable_value_for(article, name) : piece
      end.join('/')
    ensure
      article.published_at = old_published
    end

    private
      @@year_regex  = %r{^#{PERMALINK_OPTIONS[:year]}$}
      @@month_regex = %r{^#{PERMALINK_OPTIONS[:month]}$}

      def self.year?(n)
        n.nil? || n =~ @@year_regex
      end
      
      def self.month?(n)
        n.nil? || n =~ @@month_regex
      end
      
      def self.variable_value_for(article, variable)
        variable == 'id' ? article.article_id.to_s : article.send(variable).to_s
      end
  end
end