require 'sinatra/activerecord'

class Todo < ActiveRecord::Base
  validates :title, :description ,presence: true
end
