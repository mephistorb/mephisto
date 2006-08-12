module Mephisto
  module Liquid
    module DropMethods
      def self.included(base)
        base.send(:attr_reader, :source)
        [:==, :eql?, :hash].each { |m| base.delegate m, :to => :source }
      end
    end
  end
end