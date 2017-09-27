# frozen_string_literal: true

ActiveAdmin.register Visit do
  menu parent: :diagnoses, priority: 3
  permit_params :advisor_id, :visitee_id, :happened_at, :company_id, :facility_id
  includes :advisor, :visitee, :facility, facility: :company

  filter :advisor
  filter :visitee
  filter :facility_id
  filter :happened_at
  filter :created_at
  filter :updated_at
end
