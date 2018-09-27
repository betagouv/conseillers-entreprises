ActiveAdmin.register Feedback do
  menu parent: :diagnoses, priority: 4

  actions :index, :show, :update, :destroy

  permit_params :description
end
