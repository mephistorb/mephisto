xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.rss "version" => "2.0" do
  xml.channel do
    xml.title "#{site.title} Overview"
    xml.description "Recent events"
    xml.link url_for(:controller => '/admin/overview', :action => 'index')
    xml.language "en-us"
  
    @events.each do |event|
      title = "#{event.title} was " + case event.mode
        when 'publish' then "published."
        when 'create'  then "created."
        when 'edit'    then "revised."
        when 'comment' then "commented on."
      end
      
      xml.item do
        xml.title title
        xml.description event.body if event.mode == 'comment'
        xml.pubDate event.created_at.rfc822
        xml.guid "urn:uuid:#{event.id}", "isPermaLink" => "false"
        xml.author(event.mode == 'comment' ? event.author : event.user.login)
        xml.link url_for(:controller => '/admin/articles', :action => 'show', :id => event.article, :only_path => false)
      end
    end
  end
end