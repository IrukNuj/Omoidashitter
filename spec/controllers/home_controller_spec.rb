require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  describe '#indexを受け取ったとき' do

    context 'Oauth認証していなければ' do
      before do
        get :index
      end
      it 'リダイレクト処理を返すこと' do
        expect(response).to redirect_to(home_login_path)
      end
    end

    context 'Oauth認証していれば' do
      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
          'provider' => 'twitter',
          'uid'  => '2848699063',
          'info' => {
            'name'  => 'いるく',
          },
        })
        session[:user_id] = OmniAuth.config.mock_auth[:twitter].uid
        get :index
      end
      it '/index に飛ばすこと' do
        expect(response).to render_template :index
      end
    end

  end

  describe '#tweetを受け取ったとき' do

    describe 'Oauth認証していなければ' do
      before do
        get :tweet
      end
      it 'リダイレクト処理を返すこと' do
        expect(response).to redirect_to(home_login_path)
      end
    end

    context 'Oauth認証していれば' do
      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
           'provider' => 'twitter',
           'uid'  => '2848699063',
           'info' => {
             'name'  => 'いるく',
           },
         })
        session[:user_id] = OmniAuth.config.mock_auth[:twitter].uid
        get :tweet
      end
      it '/index に飛ばすこと' do
        expect(response).to render_template :tweet
      end
    end
  end

  describe '#loginを受け取った時' do
    before do
      get :login
    end
    it '/login　にアクセスできること' do
      expect(response).to render_template :login
    end
  end

end