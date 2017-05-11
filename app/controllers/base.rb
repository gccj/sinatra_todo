require 'helpers/message_helper'

class BaseController < Sinatra::Base
  helpers MessageHelper

  configure do
    root = File.dirname(__FILE__) << '/../../'
    set :public_folder, "#{root}public"
    set :views, "#{root}app/views"
    set :haml, layout: :'../views/layouts/application'
    set bind: '0.0.0.0'
    enable :sessions
    enable :logging
    register Sinatra::Reloader
  end
  
  before do
   @notice_message = session[:notice]
   @error_message = session[:error]
   clear_messages
  end

  not_found do
    'Not found'
  end
 end 
