class CreateTodos < ActiveRecord::Migration[5.1]
  def change
    create_table :todos do |t|
      t.string :title
      t.text :description
      t.boolean :done, default: false
      t.integer :role, default: 0
      t.belongs_to :user
      t.timestamps
    end
  end
end

