require 'models/user'

class UsersController < BaseController
  get '/' do
    if signed_in?
      redirect '/todos'
    else
      haml :'users/sessions/new'
    end
  end

  get '/users/sign_in' do
    if signed_in?
      flash type: :notice, messages: 'すでにログインしています'
      redirect '/todos'
    else
      haml :'users/sessions/new'
    end
  end

  post '/users/sign_in' do
    user = User.authenticate(params)
    if user
      sign_in user
      flash type: :notice, messages: "#{user.full_name}さんおかえり"
      redirect_to_original_request
    else
      flash type: :error, messages: 'メールアドレスかパスワードが違います'
      redirect '/users/sign_in'
    end
  end

  delete '/users/sign_out' do
    sign_out
    redirect '/todos'
  end

  get '/users/sign_up' do
    haml :'users/registrations/new'
  end

  post '/users/sign_up' do
    user_params = params[:user]
    user = User.new user_params
    if user.save
      sign_in User.find_by email: user.email
      flash type: :notice, messages: 'ご登録ありがとうございます'
      redirect '/todos'
    else
      flash type: :error, messages: 'ユーザー登録が失敗した。すべての項目を正しく記入してから、再登録してください'
      redirect '/users/sign_up'
    end
  end
end
