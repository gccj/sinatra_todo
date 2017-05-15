require 'models/todo'

class TodosController < BaseController
  before do
    authenticate!
  end

  get '/' do
    @todos = current_user.uncompleted_items
    haml :'todos/index'
  end

  get '/completed_items' do
    @todos = current_user.completed_items
    haml :'todos/index'
  end

  get '/new' do
    @title = '新しいToDo追加'
    haml :'todos/form'
  end

  post '/' do
    todo = current_user.todos.build(
      title: params[:todo][:title],
      description: params[:todo][:description],
      role: params[:todo][:role]
    )
    if todo.save
      flash type: :notice, messages: "新しいタスク「#{todo.title}」が正しく作成されました"
    else
      flash type: :error, messages: '登録が失敗しました、内容をチェックしてから、もう一回登録してください'
    end
    redirect '/todos'
  end

  delete '/:id' do
    todo = current_user.search_todo params[:id]
    flash type: :notice, messages: "#{todo.title}が正しく削除されました"
    todo.destroy
    redirect '/todos'
  end

  get '/:id/done' do
    todo = current_user.search_todo params[:id]
    if todo && todo.undone?
      todo.done!
      flash type: :notice, messages: '良くやりました！'
    else
      flash type: :error, messages: '無効の操作です'
    end
    redirect '/todos'
  end

  get '/shared_items' do
    @todos = Todo.shared_items
    @share = true
    last_modified @todos.maximum(:updated_at)
    cache_control :public
    haml :'todos/index'
  end
end
