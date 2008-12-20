module ActiveRecord
  class Base
    # Are ActiveRecord::Base objects currently readonly?
    def self.all_records_are_readonly?
      Thread.current[:all_records_are_readonly]
    end

    def readonly_with_global_flag?
      self.class.all_records_are_readonly? || readonly_without_global_flag?
    end
    alias_method_chain :readonly?, :global_flag

    # Make all ActiveRecord::Base objects readonly within a block.
    def self.with_readonly_records # :yield:
      saved = all_records_are_readonly?
      begin
        Thread.current[:all_records_are_readonly] = true
        yield
      ensure
        Thread.current[:all_records_are_readonly] = saved
      end
    end

    # Make all ActiveRecord::Base objects writable within a block.
    def self.with_writable_records # :yield:
      saved = all_records_are_readonly?
      begin
        Thread.current[:all_records_are_readonly] = false
        yield
      ensure
        Thread.current[:all_records_are_readonly] = saved
      end
    end
  end
end
