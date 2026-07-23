ActiveAdmin.register ApiKey do
  menu parent: :experts, priority: 4
  actions :index, :destroy
  config.filters = false

  index do
    column :id
    column :institution
    column :created_at
    column :updated_at
    column :valid_until
    actions
  end
end
