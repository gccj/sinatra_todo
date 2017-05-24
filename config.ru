# encoding: utf-8

Encoding.default_external = 'utf-8'
$LOAD_PATH.unshift(__dir__, File.join(__dir__, '/app'), File.join(__dir__, '/lib/orm'))
require 'bundler'
require 'app'
Bundler.setup
run Rack::URLMap.new(App::ROUTES)
