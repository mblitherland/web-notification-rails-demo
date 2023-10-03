class AddReasonToSubscription < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :disable_reason, :string
  end
end
