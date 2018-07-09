# frozen_string_literal: true

ActiveAdmin.register Contact do
  menu parent: :companies, priority: 2
  permit_params :full_name, :role, :company_id, :email, :phone_number
  includes :company

  ## Show
  #
  action_item :normalize_values, only: :show do
    link_to t('active_admin.person.normalize_values'), normalize_values_admin_contact_path(contact)
  end

  ## Index
  #
  index do
    selectable_column
    id_column
    column :full_name
    column :email
    column :phone_number
    column :role
    column :company
    actions dropdown: true do |contact|
      item t('active_admin.person.normalize_values'), normalize_values_admin_contact_path(contact)
    end
  end

  ## Form
  #
  form do |f|
    f.inputs do
      f.input :company, collection: Company.ordered_by_name
      f.input :full_name
      f.input :email
      f.input :phone_number
      f.input :role
    end
  end

  filter :company_name, as: :string, label: I18n.t('activerecord.attributes.facility.company')
  filter :full_name
  filter :email
  filter :phone_number
  filter :role
  filter :created_at
  filter :updated_at

  ## Actions
  #
  member_action :normalize_values do
    resource.normalize_values!
    redirect_back fallback_location: collection_path, alert: t('active_admin.person.normalize_values_done')
  end

  batch_action I18n.t('active_admin.person.normalize_values') do |ids|
    batch_action_collection.find(ids).each do |contact|
      contact.normalize_values!
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('active_admin.person.normalize_values_done')
  end
end
