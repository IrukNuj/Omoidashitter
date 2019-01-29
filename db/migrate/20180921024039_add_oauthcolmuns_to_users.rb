class AddOauthcolumnsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :oauth_token, :string
    add_column :users, :oauth_token_secret, :string
  end
end
