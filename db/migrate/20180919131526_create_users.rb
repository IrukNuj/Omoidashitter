class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :nickname
      t.string :name
      t.string :image_url
      t.string :description
      t.string :oauth_token
      t.string :oauth_token_secret
      t.string :tweet_items
      t.timestamps
    end
  end
end
