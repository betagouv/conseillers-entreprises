# frozen_string_literal: true

ActiveAdmin.register Contact do
  menu parent: :companies, priority: 2

  ## Index
  #
  includes :company

  index do
    selectable_column
    column(:coordinates, sortable: :full_name) do |c|
      div admin_link_to(c)
      div '✉ ' + (c.email || '')
      div '✆ ' + (c.phone_number || '')
    end
    column(:company) do |c|
      div admin_link_to(c, :company)
    end
    actions dropdown: true do |contact|
      item t('active_admin.person.normalize_values'), normalize_values_admin_contact_path(contact)
    end
  end

  filter :company, as: :ajax_select, data: { url: :admin_companies_path, search_fields: [:name] }
  filter :full_name
  filter :email
  filter :phone_number
  filter :created_at

  ## CSV
  #
  csv do
    column :full_name
    column :email
    column :phone_number
    column :company
  end

  ## Show
  #
  show do
    attributes_table do
      row :full_name
      row :email
      row :phone_number
      row :company
    end
  end

  action_item :normalize_values, only: :show do
    link_to t('active_admin.person.normalize_values'), normalize_values_admin_contact_path(contact)
  end

  ## Form
  #
  permit_params :full_name, :email, :phone_number, :company_id

  form do |f|
    f.inputs do
      f.input :full_name
      f.input :email
      f.input :phone_number

      f.input :company, as: :ajax_select, data: {
        url: :admin_companies_path,
        search_fields: [:name]
      }
    end

    actions
  end

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
