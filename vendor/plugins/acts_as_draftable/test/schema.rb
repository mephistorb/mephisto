ActiveRecord::Schema.define(:version => 0) do
  create_table :posts, :force => true do |t|
    t.column :title, :string
    t.column :body,  :string
  end

  Post.create_draft_table :force => true
end