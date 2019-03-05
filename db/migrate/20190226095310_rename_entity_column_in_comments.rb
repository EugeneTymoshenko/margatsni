class RenameEntityColumnInComments < ActiveRecord::Migration[5.2]
  def change
    rename_column :comments, :entity_type, :commentable_type
    rename_column :comments, :entity_id, :commentable_id
  end
end
