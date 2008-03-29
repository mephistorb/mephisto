# separately patching Rails::Plugin assuming that this patch will be accepted:
# http://dev.rubyonrails.org/ticket/10979

unless Rails::Plugin.respond_to?(:directory)
  Rails::Plugin.class_eval do
    attr_reader :directory, :name, :about
  
    alias :initialize_without_about_info :initialize
    def initialize(directory)
      initialize_without_about_info(directory)
      load_about_information
    end

    private

    def load_about_information
      begin
        about_yml_path = File.join(@directory, "about.yml")
        parsed_yml = File.exist?(about_yml_path) ? YAML.load(File.read(about_yml_path)) : {}
        @about = parsed_yml || {}
      rescue Exception
        @about = {}
      end
    end
  end
end