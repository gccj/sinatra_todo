module AuthenticationHelper
  def authenticate!
    unless session[:user]
      session[:original_request] = request.fullpath
      redirect '/users/sign_in'
    end
  end

  def signed_in?
    session[:user] ? true : false
  end

  def sign_in(user)
    session[:user] = user
  end

  def sign_out
    session[:user] = nil
  end

  def current_user
    @user ||= User.find_by id: session[:user][:id]
  end

  def redirect_to_original_request
    original_request = session[:original_request]
    session[:original_request] = nil
    redirect original_request
  end
end
