# frozen_string_literal: true

ActiveAdmin.register Diagnosis do
  menu parent: :needs, priority: 4

  ## Index
  #
  includes :facility, :company, :advisor, :needs, :matches, :solicitation
  includes facility: :commune

  scope :completed, group: :status, default: true
  scope :all, group: :status
  scope :from_solicitation, group: :solicitations
  scope :from_visit, group: :solicitations

  index do
    selectable_column
    column(:visit) do |d|
      div admin_link_to(d)
      div admin_link_to(d, :solicitation)
    end
    column :company
    column(:commune) { |d| d.facility.readable_locality || d.facility.commune }
    column :created_at
    column :step
    column :needs do |d|
      div admin_link_to(d, :needs)
      div admin_link_to(d, :matches)
    end
  end

  filter :step, as: :select, collection: Diagnosis.steps
  filter :created_at
  filter :advisor, as: :ajax_select, data: { url: :admin_users_path, search_fields: [:full_name] }
  filter :content
  filter :company, as: :ajax_select, data: { url: :admin_companies_path, search_fields: [:name] }
  filter :facility_territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }

  ## CSV
  #
  csv do
    column :company
    column(:commune) { |d| d.facility.readable_locality || d.facility.commune }
    column :content
    column :advisor
    column :created_at
    column :step
    column_count :needs
    column_count :matches
  end

  ## Show
  #
  show do
    attributes_table do
      row :solicitation
      row :facility
      row(:happened_on) { |d| d.display_date }
      row :created_at
      row :advisor
      row(:visitee) { |d| d.visitee }
      row :content
      row :step
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
      f.input :solicitation_id
      f.input :content
      f.input :step
    end

    actions
  end
end
