module ActionView
  module TemplateHandlers
    class ERB < TemplateHandler
      def compile_with_safe_erb(template)
        # This helps make new-style ActionMailer text templates do the
        # right thing automatically.  We will probably want to extend this
        # to other kinds of templates eventually.
        if template.filename.to_s =~ /\.text\.plain\.erb$/
          ::ERB.without_checking_tainted do
            compile_without_safe_erb template
          end
        else
          compile_without_safe_erb template
        end
      end

      alias_method_chain :compile, :safe_erb
    end
  end
end
