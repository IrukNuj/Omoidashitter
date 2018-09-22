class AddColumnsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :tweet_items, :string
  end
end
