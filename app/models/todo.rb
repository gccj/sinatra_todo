class Todo < ORM::Base
  belongs_to :user
  # validates :title, :description, presence: true
  enum role: %i[individual published]

  def self.shared_items
    where(role: Todo.roles[:published])
  end

  def done!
    update('done' => true)
  end

  def undone?
    !done
  end
end
