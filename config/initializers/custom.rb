# Set this if you're running under a sub directory
# ActionController::AbstractRequest.relative_url_root = '/blog'

# If it's safe to load the application, then go ahead and configure it.
if safe_to_load_application?
  require 'dispatcher'

  # TODO - We need to wrap these options in Dispatcher.to_prepare, because
  # the underlying Site, etc., objects will be unloaded on each request in
  # development mode, and the preferences will be reset.  This is a flaw
  # in how we handle configuration, and to_prepare is just a workaround.
  Dispatcher.to_prepare do
    # Turn this on to get detailed cache sweeper logging in production mode
    # Site.cache_sweeper_tracing = true

    # Enable if you want to host multiple sites on this app
    Site.multi_sites_enabled = true

    # shouldn't need to set the host, it's set automatically
    UserMailer.default_url_options[:host] = 'localhost:3000'
    UserMailer.mail_from = 'webmaster@localhost'
  end
end

# defaults to ImageScience, then RMagick, then nothing
# ASSET_IMAGE_PROCESSOR = :image_science || :rmagick || :none

# OPTIONAL - Redirections
# Deny a route by immediately returning a 404
#
#   Mephisto::Routing.deny 'articles/trackback/*' # return 404
#
# Specify multiple denied routes:
# 
#   Mephisto::Routing.deny 'articles/trackback/*', 'monkey/foo/*'
#
# Redirect elsewhere.  You can fill in variables marked by ? or * with variable names beginning with :
#
# Redirect /old/foo to /new/foo and /old/foo/bar to /new/foo/bar
#
#   Mephisto::Routing.redirect 'old/*' => 'new/$1'
#
# Redirect with a more specific set of variables
#
#   Mephisto::Routing.redirect 'article/?/?/?' => 'new/$2/$1/$3'

# Multiple redirections at a time
#
#   Mephisto::Routing.redirect \
#     'old/*' => 'new/$1',
#     'article/?/?/?' => 'new/$2/$1/$3'
