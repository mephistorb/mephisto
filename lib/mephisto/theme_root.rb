# This file needs to be loaded from both regular code and Rake tasks.

# Don't confuse themes associated with Site objects that live in different
# databases.  Doing so may cause data loss.
unless Object.const_defined?(:THEME_ROOT)
  THEME_ROOT = Pathname.new(RAILS_ROOT) +
    (Rails.env.production? ? "themes" : "themes/#{Rails.env}")
end
