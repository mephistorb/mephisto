require 'model_stubbing'
require 'spec' unless Object.const_defined?(:Spec)
(Spec.const_defined?(:ExampleGroup) ? Spec::ExampleGroup : Spec::Example).extend ModelStubbing