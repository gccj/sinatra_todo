require 'sinatra'
require 'sinatra/activerecord'
if development?
  require 'sinatra/reloader'
  require 'pry'
end
require 'haml'
require 'sass'
require 'bcrypt'
require 'controllers/base_controller'
require 'controllers/todos_controller'
require 'controllers/users_controller'

class App < Sinatra::Base
  ROUTES = {
    '/todos' => TodosController,
    '/' => UsersController
  }.freeze
end
