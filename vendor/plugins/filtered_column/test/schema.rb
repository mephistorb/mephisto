ActiveRecord::Schema.define(:version => 0) do
  create_table :articles, :force => true do |t|
    t.column :body,      :text
    t.column :body_html, :text
  end
end