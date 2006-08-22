module Mephisto
  module Attachments
    module TemplateMethods
      @@hierarchy = {
        :main    => [:home,     :section, :archive, :index],
        :single  => [:single,   :index],
        :section => [:section,  :archive, :index],
        :archive => [:archive,  :index],
        :page    => [:page,     :single,  :index],
        :search  => [:search,   :archive, :index],
        :error   => [:error,    :index]
      }.freeze
    
      @@template_types   = @@hierarchy.values.flatten.uniq << :layout
      mattr_reader :hierarchy, :template_types

      def [](template_name)
        template_name = File.basename(template_name.to_s).sub /\.liquid$/, ''
        site.attachment_path + "#{template_name =~ /layout$/ ? 'layouts' : 'templates'}/#{template_name}.liquid"
      end
    
      def find_preferred(template_type)
        hierarchy[template_type].collect { |t| self[t] }.detect(&:file?)
      end
    end
  end
end