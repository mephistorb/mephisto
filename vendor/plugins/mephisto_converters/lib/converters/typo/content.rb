module Typo
  class Content < ActiveRecord::Base
    establish_connection configurations['typo']
    set_table_name 'contents'
    belongs_to :text_filter, :class_name => 'Typo::TextFilter'
    def filter
      self.text_filter ? self.text_filter.name : nil
    end
  end
end
