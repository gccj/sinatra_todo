require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

namespace :server do
  desc 'start server'
  task :start do
    cmd = 'bundle exec rackup -o 192.168.33.33 -p 8080 -E development  -P rack.pid'
    system cmd
  end

  desc 'stop server'
  task :stop do
    file_path = File.join(__dir__, 'rack.pid')
    if File.exist?(file_path)
      File.open(file_path) do |file|
        pid = file.read
        system("kill -9 #{pid}")
      end
      FileUtils.rm file_path
    end
  end

  desc 'restart server'
  task restart: %i[stop start]
end
