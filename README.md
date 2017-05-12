# Todo アプリ

## 開発環境 
* Ruby 2.4.1 
* CentOS 7.0 
* PostgreSQL 9.2.18

## 準備作業
1. DB　ユーザーとパスワードを用意
2. /config/database.yml　にdb情報を記入
3. bundle install --path vender/bundle
4. bundle exec rake db:create
5. bundle exec rake db:migrate

## 利用
起動：(bundle exec) rake server:start
停止：(bundle exec) rake server:stop
再起動：(bundle exec) rake server:restart
