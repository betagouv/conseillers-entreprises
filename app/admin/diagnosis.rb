# frozen_string_literal: true

ActiveAdmin.register Diagnosis do
  menu priority: 7

  ##
  #
  include AdminArchivable

  ## Index
  #
  includes :facility, :company, :advisor, :diagnosed_needs, :matches
  includes facility: :commune

  scope :all

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
      status_tag t('active_admin.archivable.archive_done') if d.archived?
    end
    column :diagnosed_needs do |d|
      div admin_link_to(d, :diagnosed_needs)
      div admin_link_to(d, :matches)
    end
    actions dropdown: true do |d|
      index_row_archive_actions(d)
    end
  end

  filter :content
  filter :step
  filter :created_at
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
    column_count :diagnosed_needs
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
      row(:diagnosed_needs) do |d|
        div admin_link_to(d, :diagnosed_needs)
        div admin_link_to(d, :diagnosed_needs, list: true)
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
