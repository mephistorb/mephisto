module Typo
  class Content < ActiveRecord::Base
    establish_connection configurations['typo']
    set_table_name 'contents'
  end
end
