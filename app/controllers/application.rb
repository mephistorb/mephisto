# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include Mephisto::CachingMethods
  cattr_accessor :site_count
  before_filter  :set_cache_root
  helper_method  :site
  attr_reader    :site

  def admin?
    logged_in? && current_user.admin? || current_user.site_admin?
  end
  
  protected
    # so not the best place for this...
    def asset_image_args_for(asset, thumbnail = :tiny, options = {})
      options = options.reverse_merge(:title => "#{asset.title} \n #{asset.tags.join(', ')}")
      if asset.movie?
        ['/images/mephisto/icons/video.png', options]
      elsif asset.audio?
        ['/images/mephisto/icons/audio.png', options]
      elsif asset.pdf?
        ['/images/mephisto/icons/pdf.png', options]
      elsif asset.other?
        ['/images/mephisto/icons/doc.png', options]
      elsif asset.thumbnails_count.zero?
        [asset.public_filename, options.update(:size => Array.new(2).fill(Asset.attachment_options[:thumbnails][thumbnail].to_i).join('x'))]
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
        self.cached_references += assigns['articles']
        assigns['articles']     = assigns['articles'].collect { |a| a.to_liquid :site => site }
      end

      status          = (assigns.delete(:status) || '200 OK')
      @liquid_assigns = assigns
      render :text => site.render_liquid_for(@section, template_type, assigns, self), :status => status
    end

    def show_error(message = 'An error occurred.', status = '500 Error')
      render_liquid_template_for(:error, 'message' => message, :status => status)
    end

    def show_404
      show_error 'Page Not Found', '404 NotFound'
    end

    def set_cache_root
      host = request.domain(request.subdomains.size + (request.subdomains.first == 'www' ? 0 : 1))
      @site ||= Site.find_by_host(host) || Site.find(:first, :order => 'id')
      if @site.multi_sites_enabled
        self.class.page_cache_directory = File.join([RAILS_ROOT, (RAILS_ENV == 'test' ? 'tmp' : 'public'), 'cache', site.host])
      end
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
          render :file => File.join(RAILS_ROOT, 'public/404.html'), :status => '404 Not Found'
        else
          render :file => File.join(RAILS_ROOT, 'public/500.html'), :status => '500 Error'
      end
    end
end
