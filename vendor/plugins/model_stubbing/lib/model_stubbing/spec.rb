require 'model_stubbing'
require 'spec' unless Object.const_defined?(:Spec)
base_spec_class = \
  if defined?(Test::Unit::TestCase::ExampleGroup)
    Test::Unit::TestCase::ExampleGroup
  elsif defined?(Spec::ExampleGroup)
    Spec::ExampleGroup
  elsif defined?(Spec::Example)
    Spec::Example
  else
    raise "rspec doesn't seem to be loaded."
  end
base_spec_class.extend ModelStubbing