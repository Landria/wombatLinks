class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :user_id
      t.string :tool
      t.float :amount
      #t.bigint :ip
      t.string :payer_id
      t.boolean :is_completed, :default => false

      t.timestamps
    end
    change_table :payments do |t|
      t.foreign_key :users, :dependent => :delete
    end
    add_column :payments, :ip, :bigint
  end
end
