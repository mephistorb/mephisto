class RemoveLayoutTemplateClass < ActiveRecord::Migration
  def self.up
    ids = select_values("select id from attachments where type = #{quote_value 'LayoutTemplate'}")
    execute("update attachments set type = #{quote_value 'Template'} where id in (#{ids.collect { |i| quote_value i }.join(', ')})")
  end

  def self.down
  end
end
