# frozen_string_literal: true

ActiveAdmin.register Diagnosis do
  menu priority: 8

  ##
  #
  include AdminArchivable

  ## Index
  #
  includes :facility, :company, :advisor, :needs, :matches
  includes facility: :commune

  scope :completed, default: true
  scope :all, group: :all

  index do
    selectable_column
    column(:visit) do |d|
      div admin_link_to(d)
    end
    column :company
    column(:commune) { |d| d.facility.readable_locality || d.facility.commune }
    column :created_at
    column :step
    column :archived? do |d|
      status_tag t('archivable.archive_done') if d.archived?
    end
    column :needs do |d|
      div admin_link_to(d, :needs)
      div admin_link_to(d, :matches)
    end
    actions dropdown: true do |d|
      index_row_archive_actions(d)
    end
  end

  filter :created_at
  filter :advisor, as: :ajax_select, data: { url: :admin_users_path, search_fields: [:full_name] }
  filter :content
  filter :company, as: :ajax_select, data: { url: :admin_companies_path, search_fields: [:name] }
  filter :facility_territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }

  filter :archived_in, as: :boolean, label: I18n.t('attributes.archived?')

  ## CSV
  #
  csv do
    column :company
    column(:commune) { |d| d.facility.readable_locality || d.facility.commune }
    column :content
    column :advisor
    column :created_at
    column :step
    column :archived?
    column_count :needs
    column_count :matches
  end

  ## Show
  #
  show do
    attributes_table do
      row :facility
      row(:happened_on) { |d| d.display_date }
      row :created_at
      row :advisor
      row(:visitee) { |d| d.visitee }
      row :content
      row :step
      row :archived_at
      row(:needs) do |d|
        div admin_link_to(d, :needs)
        div admin_link_to(d, :needs, list: true)
      end
      row(:matches) do |d|
        div admin_link_to(d, :matches)
        div admin_link_to(d, :matches, list: true)
      end
    end
  end

  ## Form
  #
  permit_params :content, :step

  form do |f|
    f.inputs do
      f.input :content
      f.input :step
    end

    actions
  end
end
