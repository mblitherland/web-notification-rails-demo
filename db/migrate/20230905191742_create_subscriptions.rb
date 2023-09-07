class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.string :endpoint
      t.string :p256dh
      t.string :auth
      t.integer :user_id

      t.timestamps
    end
  end
end
