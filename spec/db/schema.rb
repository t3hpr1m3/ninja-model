ActiveRecord::Schema.define do
  create_table :users, :force => true do |t|
    t.string :username
  end

  create_table :tags, :force => true do |t|
    t.integer :post_id
    t.string :name
  end

  create_table :email_addresses, :force => true do |t|
    t.integer :bio_id
    t.string :email
  end
end
