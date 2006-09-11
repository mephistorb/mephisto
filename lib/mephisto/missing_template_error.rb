module Mephisto
  class MissingTemplateError < StandardError
    def initialize(template_name)
      super "'#{template_name}' is missing."
    end
  end
end