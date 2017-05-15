require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'haml'
require 'sass'
require 'controllers/base'
require 'controllers/todo'

class App < Sinatra::Base
  ROUTES = {
    '/' => TodoController
  }.freeze
end
