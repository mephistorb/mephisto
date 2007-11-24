require 'model_stubbing'
require 'test/unit/test_case' unless Object.const_defined?(:Test)
Test::Unit::TestCase.extend ModelStubbing