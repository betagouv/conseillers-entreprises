# frozen_string_literal: true

ActiveAdmin.register Diagnosis do
  menu priority: 7
  actions :index, :show
  includes visit: [facility: :company]

  controller do
    def scoped_collection
      Diagnosis.unscoped
    end
  end

  filter :visit, collection: -> { Visit.includes(facility: :company).joins(facility: :company).order('companies.name') }
  filter :content
  filter :created_at
  filter :updated_at
  filter :deleted_at
  filter :step
end
