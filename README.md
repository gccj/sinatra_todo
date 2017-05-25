## Todo アプリ

#### 開発環境
* Ruby 2.4.1
* CentOS 7.0
* MySQL 5.5.52

#### 準備作業
1. データベースを用意
2. データベースの情報をconfig/database.ymlに記入
3. bundle install --path vendor/bundle
4. (bundle exec) rake db:create
5. (bundle exec) rake db:migrate

#### 利用
* 起動：(bundle exec) rake server:start
* 停止：(bundle exec) rake server:stop
* 再起動：(bundle exec) rake server:restart
