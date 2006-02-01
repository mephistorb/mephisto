module Typo
  class Tag < ActiveRecord::Base
    establish_connection configurations['typo']
    has_and_belongs_to_many :tags, :class_name => 'Typo::Article'
  end
end
