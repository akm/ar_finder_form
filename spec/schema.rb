ActiveRecord::Schema.define(:version => 0) do
  # Users are created and updated by other Users
  create_table :products, :force => true do |t|
    t.string :category_cd
    t.string :code
    t.string :name
    t.float :price
    t.integer :stock
    t.time :released_at
    t.timestamp
  end

  create_table :orders, :force => true do |t|
    t.integer :user_id
    t.integer :product_id
    t.integer :amount
    t.float :price
    t.date :delivery_estimate
    t.time :delivered_at
    t.time :deleted_at 
    t.timestamp
  end
 
  create_table :users, :force => true do |t|
    t.string :login
    t.string :name
    t.timestamp
  end
 
end
