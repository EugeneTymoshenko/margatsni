class CreateImages < ActiveRecord::Migration[5.2]
  def change
    create_table :images do |t|
      t.references :entity, polymorphic: true
      t.string :file_data, null: false

      t.timestamps
    end
  end
end
