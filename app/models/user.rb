class User < ActiveRecord::Base
  has_many :todos
  has_secure_password

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/ }
  validates :password, presence: true, length: { in: 6..20 }

  def full_name
    "#{first_name}#{last_name}"
  end

  def self.authenticate(params = {})
    return nil if params[:user][:email].blank? || params[:user][:password].blank?
    user = find_by email: params[:user][:email]
    user if user && user.authenticate(params[:user][:password])
  end

  def uncompleted_items
    todos.where('done = ?', false).order('created_at DESC')
  end

  def completed_items
    todos.where('done = ?', true).order('created_at DESC')
  end

  def search_todo(id)
    todos.find_by id: id
  end

  # def authenticate(password)
  # self.password == password
  # end
end
