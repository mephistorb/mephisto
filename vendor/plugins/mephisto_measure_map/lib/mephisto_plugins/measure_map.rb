module MephistoPlugins
  module MeasureMap
    include ActionView::Helpers::JavascriptHelper

    def measure_map_comment(comment)
      javascript_tag(%Q{if(!mmcomments){var mmcomments=[];}mmcomments[mmcomments.length]="#{comment['id']}";}) +
      %Q{<!-- mmc mmid:#{comment['id']} mmdate:#{format_date(comment['created_at'], :db)} mmauthor:#{escape_html comment['author']} -->}
    end

    def measure_map_post(article)
      javascript_tag(%Q{if(!mmposts){var mmposts=[];}mmposts[mmposts.length]="#{article['id']}";}) +
      %Q{<!-- mmp mmid:#{article['id']} mmdate:#{format_date(article['published_at'], :db)} mmurl:#{article['url']} mmtitle:#{escape_html(article['title'])} -->}
    end

    def measure_map_footer(foo)
      content_tag :script, nil, :type => 'text/javascript', :src => 'http://tracker.measuremap.com/a/413'
    end
  end
end