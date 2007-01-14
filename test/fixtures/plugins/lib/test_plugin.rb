module Mephisto
  module Plugins
    class TestPlugin < Mephisto::Plugin
      homepage 'http://foo.com'
      author 'Captain Problematic'
      version 'deathstar'

      default_options \
        :config  => {'one' => 'test'},
        :notes   => 'notes'
      
    end
  end
end