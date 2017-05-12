require 'models/todo'

class TodoController < BaseController
  get '/' do
    @todos = Todo.all
    haml :index
  end

  get '/todos/new' do
    @title = '新しいToDo追加'
    haml :form
  end

  post '/todos' do
    todo = Todo.new(
        title: params[:todo][:title],
        description: params[:todo][:description]
    )
    if todo.valid?
      todo.save
      flash type: :notice, messages: "新しいタスク#{todo.title}が正しく作成されました"
      redirect '/'
    else
      flash type: :error, messages: '登録が失敗しました、内容をチェックしてから、もう一回登録してください'
      redirect '/'
    end
  end

  get '/todos/:id/done' do
    todo = Todo.find_by_id params[:id]
    todo.done = true
    todo.save!
    redirect '/'
  end
end

