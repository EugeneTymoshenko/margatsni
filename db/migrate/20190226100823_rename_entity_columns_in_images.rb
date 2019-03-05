class RenameEntityColumnsInImages < ActiveRecord::Migration[5.2]
  def change
    rename_column :images, :entity_type, :imageable_type
    rename_column :images, :entity_id, :imageable_id
  end
end
