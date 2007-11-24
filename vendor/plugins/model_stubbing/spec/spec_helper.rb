dir = File.dirname(__FILE__)

# look for spec as plugin, in lib, or as a gem
$LOAD_PATH << File.join(dir, '..', '..', 'rspec', 'lib')
$LOAD_PATH << File.join(dir, '..', '..', '..', 'rspec', 'lib')
begin
  require 'spec'
rescue LoadError
  # doh, get it from a gem then
  require 'rubygems'
  require 'spec'
end

require File.join(File.dirname(__FILE__), 'models')