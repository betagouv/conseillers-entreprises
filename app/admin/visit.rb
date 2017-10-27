# frozen_string_literal: true

ActiveAdmin.register Visit do
  menu parent: :diagnoses, priority: 3
  actions :index, :show
  permit_params :advisor_id, :visitee_id, :happened_on, :company_id, :facility_id
  includes :advisor, :visitee, :facility, facility: :company

  filter :advisor, collection: -> { User.ordered_by_names }
  filter :visitee, collection: -> { Contact.ordered_by_names }
  filter :facility, collection: (lambda do
    Facility.includes(:company).joins(:company).order('companies.name').map { |f| [f.company.name, f.siret] }
  end)
  filter :happened_on
  filter :created_at
  filter :updated_at
end
