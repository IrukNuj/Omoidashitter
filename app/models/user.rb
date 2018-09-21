class User < ApplicationRecord
  def self.find_or_create_from_auth(auth)
    # ここ何やってるか全くわかんねぇ。
    # Oauth取得 → セッション保存 → 書き換え みたいなことやってるの?(
    provider = auth[:provider]
    uid = auth[:uid]
    nickname = auth[:info][:nickname]
    name = auth[:info][:name]
    image_url = auth[:info][:image]
    description = auth[:info][:description]

    # わからんけどアクセストークン欲しいから貰えそうなコード追記
    oauth_token = auth[:credentials][:token]
    oauth_token_secret = auth[:credentials][:secret]

    self.find_or_create_by(provider: provider, uid: uid) do |user|
      user.nickname = nickname
      user.name = name
      user.image_url = image_url
      user.description = description
      user.oauth_token = oauth_token
      user.oauth_token_secret = oauth_token_secret
    end
  end
end
