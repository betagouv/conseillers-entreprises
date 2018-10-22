ActiveAdmin.register Feedback do
  menu parent: :diagnoses, priority: 4
  permit_params :description
  includes :match

  actions :index, :show, :update, :destroy
end
