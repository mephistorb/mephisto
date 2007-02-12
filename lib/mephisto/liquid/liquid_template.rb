module Mephisto
  module Liquid
    class LiquidTemplate

      def initialize(site)
        @site = site
      end
  
      def render(section, layout, template, assigns ={}, controller = nil)
        parse_inner_template(template, assigns, controller)
        parse_template(layout, assigns, controller)
      end  

      def parse_template(template, assigns, controller)
        # give the include tag access to files in the site's fragments directory
        ::Liquid::Template.file_system = ::Liquid::LocalFileSystem.new(File.join(@site.theme.path, 'templates'))
        tmpl = ::Liquid::Template.parse(template.read.to_s)
        returning tmpl.render(assigns, :registers => {:controller => controller}) do |result|
          yield tmpl, result if block_given?
        end
      end
  
      def parse_inner_template(template, assigns, controller)
        parse_template(template, assigns, controller) do |tmpl, result|
          # Liquid::Template takes a copy of the assigns.  
          # merge any new values in to the assigns and pass them to the layout
          tmpl.assigns.each { |k, v| assigns[k] = v } if tmpl.respond_to?(:assigns)
          assigns['content_for_layout'] = result
        end
      end  
    end
  end
end
