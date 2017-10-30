# frozen_string_literal: true

ActiveAdmin.register Institution do
  menu parent: :experts, priority: 1
  permit_params :name, :email, :phone_number

  show do
    attributes_table do
      row :name
      row :email
      row :phone_number
      row :created_at
      row :updated_at
    end

    panel I18n.t('active_admin.institutions.experts') do
      column_title = I18n.t('activerecord.attributes.expert.full_name')
      table_for institution.experts do
        column column_title, (proc { |expert| link_to(expert, admin_expert_path(expert)) })
      end
    end
  end

  filter :experts, collection: -> { Expert.ordered_by_names }
  filter :name
  filter :email
  filter :phone_number
  filter :created_at
  filter :updated_at
  filter :qualified_for_commerce
  filter :qualified_for_artisanry
end
