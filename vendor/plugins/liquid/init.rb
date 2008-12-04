require 'liquid'
require 'extras/liquid_view'

ActionView::Template::register_template_handler :liquid, LiquidView
  
  
