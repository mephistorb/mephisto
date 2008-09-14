xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

xml.feed "xml:lang" => "#{site.lang || 'en-US'}", "xmlns" => 'http://www.w3.org/2005/Atom' do
  xml.title       "#{site.title || 'Mephisto'} - #{@section ? @section.name : 'All'}#{' Comments' if @comments && @articles.nil?}"
  xml.id          "tag:#{request.host},#{Time.now.utc.year}:mephisto#{"/#{@section.path}" if @section}#{ '/comments' if @comments && @articles.nil?}"
  xml.generator   "Mephisto #{Mephisto::Version::TITLE}", :uri => "http://mephistoblog.com", :version => "#{Mephisto::Version::STRING}"
  xml.link "rel" => "self",      "type" => "application/atom+xml", "href" => url_for(:only_path => false)
  xml.link "rel" => "alternate", "type" => "text/html",
    "href" => @section ? dispatch_url(@section.hash_for_url(:only_path => false)) : dispatch_url(:path => [])

  if @articles && @articles.any?
    xml.updated @articles.first.updated_at.xmlschema unless @articles.empty?
    @articles.each do |article|
      render :partial => 'article', :locals => {:article => article, :xm => xml}
    end
  end

  if @comments && @comments.any?
    xml.updated @comments.first.updated_at.xmlschema unless @comments.empty?
    @comments.each do |comment|
      render :partial => 'comment', :locals => {:comment => comment, :article => comment.article, :xm => xml}
    end
  end
end
