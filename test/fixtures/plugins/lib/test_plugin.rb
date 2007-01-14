module MephistoPlugins
  class TestPlugin < MephistoPlugin
    homepage 'http://foo.com'
    author 'Captain Problematic'
    version 'deathstar'

    option :config, 'one' => 'test'
    option :notes, 'notes'
  end
end