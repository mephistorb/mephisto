module Technoweenie
  module DialogHelper
    # Generates a javascript call to create a Dialog.  Dialog options are camelized and quoted, with the exception
    # of callbacks starting with 'on_'.
    #
    #   <%= create_dialog(:confirm, 
    #         :message => 'Are you sure?', 
    #         :okay_test => 'Sure!', 
    #         :on_okay => "function() { alert('whoa'); }") %>
    #
    #   new Dialog.Confirm({message:'Are you sure?', okayTest:'Sure!', onOkay:function() { alert('whoa'); }});
    #
    def create_dialog(dialog_type, options = {})
      "new Dialog.#{dialog_type.to_s.camelize}(#{options_for_dialog options});"
    end
    
    # Generates a link that creates a Dialog.  Uses the same options as #create_dialog.
    #
    #   <%= link_to_dialog('Open', {:confirm, 
    #         :message => 'Are you sure?', 
    #         :on_okay => "function() { alert('whoa'); }"},
    #        {:title => 'Click to open dialog'}) %>
    #
    #   <a href="#" title="Click to open dialog"
    #     onclick="new Dialog.Confirm({message:'Are you sure?', onOkay:function() { alert('whoa'); }});; return false;">
    #     Open
    #   </a>
    def link_to_dialog(text, dialog_type, options = {}, html_options = {})
      link_to_function(text, create_dialog(dialog_type, options), html_options)
    end
    
    protected
    def options_for_dialog(dialog_options = {})
      options_for_javascript(dialog_options.inject({}) { |options, d|
        options.merge((d.first.to_s[0..0] << d.first.to_s.camelize[1..-1]) => (d.first.to_s =~ /^on_/ ? d.last : %('#{d.last}')))
      })
    end
  end
end