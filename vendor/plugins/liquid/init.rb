require 'liquid'
require 'extras/liquid_view'

ActionView::Base::register_template_handler :liquid, LiquidView
  
  
