module TextPattern
  class Article < ActiveRecord::Base
    set_table_name 'textpattern'
    set_primary_key 'ID'
    establish_connection configurations['tp']
    has_many :comments, :foreign_key => 'parentid', :class_name => 'TextPattern::Comment'
  end
end
