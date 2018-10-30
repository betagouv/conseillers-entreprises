ActiveAdmin.register Commune do
  menu parent: :territories, priority: 2
  includes :territories

  filter :insee_code
  filter :created_at
  filter :updated_at
end
