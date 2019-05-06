Trestle.resource(:users) do
  menu do
    item :users, icon: "fa fa-male"
  end

  search do |query|
    if query
      User.where("username ILIKE ?", "%#{query}%")
    else
      User.all
    end
  end

  table do
    column :id
    column :username
    column :email
    column :created_at
    column :updated_at
    column :bio
    actions
  end

  form do
    text_field :username
    text_field :email
    text_field :bio
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:post).permit(:name, ...)
  # end
end
