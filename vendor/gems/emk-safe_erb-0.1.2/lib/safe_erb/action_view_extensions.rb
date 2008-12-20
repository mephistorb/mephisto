module ActionView
  Renderable.class_eval do
    def compiled_source_with_safe_erb
      # This helps make new-style ActionMailer text templates do the
      # right thing automatically.  We will probably want to extend this
      # to other kinds of templates eventually.
      if filename.to_s =~ /\.text\.plain\.erb\z/
        compiled_source_without_safe_erb
      else
        ::ERB.with_checking_tainted do
          compiled_source_without_safe_erb
        end
      end
    end
    
    alias_method_chain :compiled_source, :safe_erb
  end
end
