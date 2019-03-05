class Role < ApplicationRecord
  extend Enumerize

  belongs_to :user

  enumerize :name, %i[admin member], default: :member
end
