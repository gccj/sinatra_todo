# Todo アプリ

## 開発環境
* Ruby 2.4.1
* CentOS 7.0
* SQLite

## 準備作業
1. bundle install --path vendor/bundle
2. bundle exec rake db:migrate

## 利用
* 起動：(bundle exec) rake server:start
* 停止：(bundle exec) rake server:stop
* 再起動：(bundle exec) rake server:restart
