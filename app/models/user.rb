class User < ORM::Base
  has_many :todos
  # validates :first_name, presence: true
  # validates :last_name, presence: true
  # validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/ }
  # validates :password, presence: true, length: { in: 6..20 }
  include BCrypt

  def password
    @password ||= Password.new(password_digest)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_digest = @password
  end

  def full_name
    "#{first_name}#{last_name}"
  end

  def self.authenticate(params = {})
    return nil if params[:user][:email].empty? || params[:user][:password].empty?
    user = find_by email: params[:user][:email]
    user if user && user.authenticate(params[:user][:password])
  end

  def uncompleted_items
    todos.where(done: false)
  end

  def completed_items
    todos.where(done: true)
  end

  def search_todo(id)
    todos.find_by id: id
  end

  def authenticate(password)
    self.password == password
  end
end
