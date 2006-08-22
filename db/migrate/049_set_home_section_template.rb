class SetHomeSectionTemplate < ActiveRecord::Migration
  class Section < ActiveRecord::Base ; end
  def self.up
    Section.update_all "template = 'home'", "path = 'home'"
  end

  def self.down
  end
end
