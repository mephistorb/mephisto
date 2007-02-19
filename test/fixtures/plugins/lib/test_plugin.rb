module Mephisto
  module Plugins
    class TestPlugin < Mephisto::Plugin
      homepage 'http://foo.com'
      author 'Captain Problematic'
      version 'deathstar'
    
      option :config, 'one' => 'test'
      option :notes, 'notes'
    end
  end
end