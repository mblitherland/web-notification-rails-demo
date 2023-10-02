class AddEnabledAndUaToSubscription < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :enabled, :boolean
    add_column :subscriptions, :user_agent, :string
  end
end
