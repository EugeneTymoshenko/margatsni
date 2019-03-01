class EditRolesAsotiation < ActiveRecord::Migration[5.2]
  def change
    remove_belongs_to :users, :role, foreign_key: true
    add_belongs_to :roles, :user, foreign_key: true
  end
end
