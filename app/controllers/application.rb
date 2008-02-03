class ApplicationController < ActionController::Base
  include Mephisto::CachingMethods
  cattr_accessor :site_count # what is this for?  PDI removing
  before_filter  :set_cache_root
  helper_method  :site
  attr_reader    :site

  auto_include!
  def self.inherited(klass)
    super
    klass.auto_include!
  end
  
  filter_parameter_logging "password"
  
  protected
    helper_method :admin?
    helper_method :global_admin?
    
    def admin?
      logged_in? && (current_user.admin? || current_user.site_admin?)
    end
  
    def global_admin?
      logged_in? && current_user.admin?
    end
      
    # so not the best place for this...
    def asset_image_args_for(asset, thumbnail = :tiny, options = {})
      thumb_size = Array.new(2).fill(Asset.attachment_options[:thumbnails][thumbnail].to_i).join('x')
      options    = options.reverse_merge(:title => "#{asset.title} \n #{asset.tags.join(', ')}", :size => thumb_size)
      if asset.movie?
        ['/images/mephisto/icons/video.png', options]
      elsif asset.audio?
        ['/images/mephisto/icons/audio.png', options]
      elsif asset.pdf?
        ['/images/mephisto/icons/pdf.png', options]
      elsif asset.other?
        ['/images/mephisto/icons/doc.png', options]
      elsif asset.thumbnails_count.zero?
        [asset.public_filename, options]
      else
        [asset.public_filename(thumbnail), options]
      end
    end
    helper_method :asset_image_args_for

    [:utc_to_local, :local_to_utc].each do |meth|
      define_method meth do |time|
        site.timezone.send(meth, time)
      end
      helper_method meth
    end

    def render_liquid_template_for(template_type, assigns = {})
      headers["Content-Type"] ||= 'text/html; charset=utf-8'
      if assigns['articles'] && assigns['article'].nil?
        # use collect so it doesn't modify @articles
        assigns['articles'] = assigns['articles'].collect &:to_liquid 
      end
      status          = (assigns.delete(:status) || :ok)
      @liquid_assigns = assigns
      render :text => site.call_render(@section, template_type, assigns, self), :status => status
    end

    def show_error(message = 'An error occurred.', status = :internal_server_error)
      render_liquid_template_for(:error, 'message' => message, :status => status)
    end

    def show_404
      show_error 'Page Not Found', :not_found
    end

    def set_cache_root
      host = request.domain(request.subdomains.size + (request.subdomains.first == 'www' ? 0 : 1))
      @site ||= Site.find_by_host(host) || Site.find(:first, :order => 'id')
      self.class.page_cache_directory = site.page_cache_directory.to_s
    end

    def with_site_timezone
      old_tz = ENV['TZ']
      ENV['TZ'] = site.timezone.name
      yield
      ENV['TZ'] = old_tz
    end
    
    def rescue_action_in_public(exception)
      logger.debug "#{exception.class.name}: #{exception.to_s}"
      exception.backtrace.each { |t| logger.debug " > #{t}" }
      case exception
        when ActiveRecord::RecordNotFound, ::ActionController::UnknownController, ::ActionController::UnknownAction
          render :file => File.join(RAILS_ROOT, 'public/404.html'), :status => :not_found
        else
          render :file => File.join(RAILS_ROOT, 'public/500.html'), :status => :internal_server_error
      end
    end
end
