class Role < ApplicationRecord
  extend Enumerize

  belongs_to :user

  enumerize :name, in: %i[admin member], default: :member
end
