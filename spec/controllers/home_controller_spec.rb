require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe '#indexを受け取ったとき' do
    before do
      get :index
    end

    describe 'session[:user_id]に値がなければ' do
      before do
        session[:user_id] = nil
      end
      it 'リダイレクト処理を返すこと' do
        expect(response).to redirect_to(home_login_path)
      end
    end
  end

  describe '#tweetを受け取ったとき' do
    before do
      get :tweet
    end

    describe 'session[:user_id]に値がなければ' do
      before do
        session[:user_id] = nil
      end
      it 'リダイレクト処理を返すこと' do
        expect(response).to redirect_to(home_login_path)
      end
    end
  end

  describe '#loginを受け取った時' do
    it '200ステータスを返すこと' do
      expect(response.status).to eq 200
    end
  end

end