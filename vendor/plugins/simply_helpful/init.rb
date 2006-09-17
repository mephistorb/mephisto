require 'simply_helpful'
ActionController::Base.helper(SimplyHelpful::RecordIdentificationHelper, SimplyHelpful::RecordTagHelper)