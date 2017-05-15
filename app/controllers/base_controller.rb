require 'helpers/message_helper'
require 'helpers/authentication_helper'

class BaseController < Sinatra::Base
  helpers MessageHelper, AuthenticationHelper
  configure do
    root = File.dirname(__FILE__) << '/../../'
    set :public_folder, "#{root}public"
    set :views, "#{root}app/views"
    set :haml, layout: :'../views/layouts/application'
    set :sass, style: :compact
    set bind: '0.0.0.0'
    enable :sessions
    enable :logging
    enable :method_override
  end

  configure :development do
    register Sinatra::Reloader
  end

  before do
    @notice_message = session[:notice]
    @error_message = session[:error]
    clear_messages
  end

  not_found do
    haml :'404'
  end

  get '/stylesheets/styles.css' do
    scss :"../../public/stylesheets/styles"
  end
end
