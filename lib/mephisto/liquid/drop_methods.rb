module Mephisto
  module Liquid
    module DropMethods
      def self.included(base)
        base.send(:attr_reader, :source)
        base.delegate :hash, :to => :source
      end
      
      def eql?(comparison_object)
        self == (comparison_object)
      end
      
      def ==(comparison_object)
        self.source == (comparison_object.is_a?(self.class) ? comparison_object.source : comparison_object)
      end
    end
  end
end