# frozen_string_literal: true

ActiveAdmin.register Diagnosis do
  menu priority: 7

  ## Index
  #
  includes :visit, :facility, :company, :advisor
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
      row :visit
      row :content
      row(:advisor)
      row :created_at
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

    panel I18n.t('activerecord.models.diagnosed_need.other') do
      table_for diagnosis.diagnosed_needs do
        column(:id) { |n| link_to(n.id, admin_diagnosed_need_path(n)) }
        column(:category) { |n| n.question&.category&.label }
        column :question_label
        column(:content) { |n| link_to(n.content, admin_diagnosed_need_path(n)) }
      end
    end

    render partial: 'admin/matches', locals: { matches: diagnosis.matches }
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
