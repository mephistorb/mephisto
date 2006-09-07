module Mephisto
  module Attachments
    module TemplateMethods
      @@hierarchy = {
        :section => [:section,  :archive, :index],
        :page    => [:page,     :single,  :index],
        :single  => [:single,   :index],
        :archive => [:archive,  :index],
        :search  => [:search,   :archive, :index],
        :error   => [:error,    :index]
      }
    
      @@template_types = (@@hierarchy.values.flatten.uniq << :layout).collect! { |f| "#{f}.liquid" }
      @@template_types.sort!
      mattr_reader :hierarchy, :template_types

      def [](template_name)
        template_name = File.basename(template_name.to_s).sub /\.liquid$/, ''
        site.attachment_path + "#{template_name =~ /layout$/ ? 'layouts' : 'templates'}/#{template_name}.liquid"
      end
    
      def find_preferred(template_type)
        hierarchy[template_type].collect { |t| self[t] }.detect(&:file?)
      end
      
      def custom
        @custom ||= collect { |p| p.basename.to_s } - template_types
      end
    end
  end
end