class RenameEntityColumnsInLikes < ActiveRecord::Migration[5.2]
  def change
    rename_column :likes, :entity_type, :likeable_type
    rename_column :likes, :entity_id, :likeable_id
  end
end
