class RemoveLayoutTemplateClass < ActiveRecord::Migration
  def self.up
    ids = select_values("select id from attachments where type = #{quote 'LayoutTemplate'}")
    execute("update attachments set type = #{quote 'Template'} where id in (#{ids.collect { |i| quote i }.join(', ')})")
  end

  def self.down
  end
end
