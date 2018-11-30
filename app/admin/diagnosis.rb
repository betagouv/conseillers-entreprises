# frozen_string_literal: true

ActiveAdmin.register Diagnosis do
  menu priority: 7

  ## Index
  #
  includes :visit, :facility, :company, :advisor, :diagnosed_needs, :matches
  includes facility: :commune

  scope :only_active, default: true
  scope :all

  index do
    selectable_column
    column(:visit) do |d|
      div admin_link_to(d)
      div admin_attr(d, :content)
    end
    column(:advisor)
    column :created_at
    column :step
    column :archived? do |d|
      if d.archived?
        status_tag :archived, class: 'warning'
        span I18n.l(d.archived_at, format: '%Y-%m-%d %H:%M')
      end
    end
    column :diagnosed_needs do |d|
      div admin_link_to(d, :diagnosed_needs)
      div admin_link_to(d, :matches)
    end
    actions dropdown: true
  end

  filter :company, as: :ajax_select, data: { url: :admin_companies_path, search_fields: [:name] }
  filter :created_at
  filter :archived_at
  filter :step

  ## CSV
  #
  csv do
    column :facility
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
      row(:happened_on) { |d| d.visit.display_date }
      row :created_at
      row :advisor
      row(:visitee) { |d| d.visit.visitee }
      row :content
      row :step
      row :archived? do |d|
        if d.archived?
          status_tag :archived, class: 'warning'
          span I18n.l(d.archived_at, format: '%Y-%m-%d %H:%M')
        end
      end
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
  permit_params :content, :archived_at, :step

  form do |f|
    f.inputs do
      f.input :content
      f.input :step
      f.input :archived_at
    end

    actions
  end
end
