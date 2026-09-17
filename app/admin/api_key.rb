ActiveAdmin.register ApiKey do
  menu parent: :experts, priority: 4
  actions :index, :edit, :update, :destroy
  config.filters = false

  permit_params scopes: []

  index do
    column :id
    column :institution
    column :scopes do |api_key|
      api_key.scopes.join(', ')
    end
    column :created_at
    column :updated_at
    column :valid_until
    actions
  end

  form do |f|
    f.inputs do
      f.input :scopes, as: :check_boxes, collection: ApiKey::SCOPES
    end
    f.actions
  end
end
