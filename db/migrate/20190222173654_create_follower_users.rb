class CreateFollowerUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :follower_users do |t|
      t.belongs_to :follower, foreign_key: { to_table: :users }
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
