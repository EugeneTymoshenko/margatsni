class FollowerUser < ApplicationRecord
  belongs_to :user # subscription object
  belongs_to :follower, class_name: 'User' # the guy who follows
end
