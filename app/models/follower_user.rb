class FollowerUser < ApplicationRecord
  belongs_to :user
  belongs_to :follower, foreign_key: { to_table: :users }
end
