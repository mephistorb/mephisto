module TextPattern
  class Comment < ActiveRecord::Base
    establish_connection configurations['tp']
    set_primary_key 'discussid'
    set_table_name 'txp_discuss'
    belongs_to :article, :foreign_key => 'parentid', :class_name => 'TextPattern::Comment'
  end
end
