# Object model of a plugin in plugins/vendor. May or may not have an internal Mephisto::Plugins::Plugin (an AR).
module Mephisto
  class DirectoryPlugin
    @@filter = /^mephisto_(\w+)$/
    attr_accessor :plugin, :path
    
    def self.scan
      Dir.new("#{RAILS_ROOT}/vendor/plugins/").collect do |entry|
        # don't list "invisible" plugins nor directories/files hidden on the filesystem
        entry =~ @@filter ? new($1) : nil
      end.compact
    end
    
    def initialize(path)
      @path = path
    end
    
    def klass
      @klass ||= Mephisto::Plugin[@path] rescue :false
    end
    
    def configurable?
      klass != :false
    end
  end
end