# Todo アプリ

## 開発環境 
* Ruby 2.4.1 
* CentOS 7.0 
* PostgreSQL 9.2.18

## 動作手順
1. DB　ユーザーとパスワードを用意
2. /config/database.yml　にdb情報を記入
3. bundle install --path vender/bundle
4. bundle exec rake db:create
5. bundle exec rake db:migrate
6. bundle exec rackup --host --port -E development
