module Mephisto
  module Integration
    module Actor
      def read(record = nil)
        url = case record
          when Article then record.full_permalink
          when Section then record.to_url * '/'
          else record.to_s
        end
        get url
        assert_equal 200, status
      end

      def syndicate(section)
        get "/feed/#{section.to_feed_url * '/'}"
        assert_equal 200, status
      end

      def comment_on(article, comment)
        post "#{article.full_permalink}/comment", :comment => comment
      end

      def approve_comment(comment)
        manage_comment :approve, comment
      end

      def unapprove_comment(comment)
        manage_comment :unapprove, comment
      end

      def revise(article, contents)
        post "/admin/articles/update/#{article.id}", to_article_params(article, contents.is_a?(Hash) ? contents : {:body => contents})
        assert_redirected_to "/admin/articles"
      end

      def create(params)
        post '/admin/articles/create', to_article_params(params)
        assert_redirected_to "/admin/articles"
      end

      private
        def manage_comment(action, comment)
          post "/admin/articles/#{action}/#{comment.article_id}", :comment => comment.id
        end

        def to_article_params(*args)
          options = args.pop
          article = args.first
          if article
            options[:published_at] ||= article.published_at
            options[:sections]     ||= article.sections
            [:title, :excerpt, :body].each { |key| options[key] ||= article.send(key) }
          end

          params = [:title, :excerpt, :body].inject({}) { |params, key| params.merge "article[#{key}]" => options[key] }
          add_published_at! params, options[:published_at] if options[:published_at].is_a?(Time)
          params[:submit] = options[:submit] || 'save'
          params[:submit] = 'Save as Draft' if params[:submit] == :draft
          params = params.keys.inject([]) { |all, k| params[k] ? all << "#{k}=#{CGI::escape params[k].to_s}" : all } # change to an array so we can add multiple sections
          add_section_ids! params, options[:sections]
          params * '&'
        end

        def add_published_at!(params, date)
          params.update to_date_params(:article, :published_at, date)
        end

        def add_section_ids!(params, sections)
          (sections || []).each { |s| params << "article[section_ids][]=#{s.id}" }
        end

        def to_date_params(object, method, date)
          {
            "#{object}[#{method}(1i)]" => date.year.to_s,
            "#{object}[#{method}(2i)]" => date.month.to_s,
            "#{object}[#{method}(3i)]" => date.day.to_s,
            "#{object}[#{method}(4i)]" => date.hour.to_s,
            "#{object}[#{method}(5i)]" => date.min.to_s
          }
        end
    end
  end
end