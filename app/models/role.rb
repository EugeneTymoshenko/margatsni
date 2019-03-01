class Role < ApplicationRecord
  extend Enumerize

  belongs_to :user

  enumerize :name, in: [:admin, :member], default: :member
end
