module Typo
  class TextFilter < ActiveRecord::Base
    establish_connection configurations['typo']
    has_and_belongs_to_many :articles, :class_name => 'Typo::Filter'
  end
end