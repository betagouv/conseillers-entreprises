# frozen_string_literal: true

ActiveAdmin.register Institution do
  menu parent: :experts, priority: 2

  ## Index
  #
  includes :antennes, :advisors, :experts, :sent_matches, :received_matches
  config.sort_order = 'name_asc'

  index do
    selectable_column
    column(:name) do |i|
      div admin_link_to(i)
      div admin_link_to(i, :antennes)
    end
    column(:community) do |i|
      div admin_link_to(i, :advisors)
      div admin_link_to(i, :experts)
    end
    column(:activity) do |i|
      div admin_link_to(i, :sent_matches)
      div admin_link_to(i, :received_matches)
    end
  end

  filter :name

  ## CSV
  #
  csv do
    column :name
    column_count :antennes
    column_count :advisors
    column_count :experts
    column_count :sent_matches
    column_count :received_matches
  end

  ## Show
  #
  show do
    attributes_table do
      row :name
      row(:antennes) do |i|
        div admin_link_to(i, :antennes)
      end
      row(:community) do |i|
        div admin_link_to(i, :advisors)
        div admin_link_to(i, :experts)
      end
      row(:activity) do |i|
        div admin_link_to(i, :sent_matches)
        div admin_link_to(i, :received_matches)
      end
      row :show_icon
    end
  end

  ## Form
  #
  permit_params :name, :show_icon, antenne_ids: []

  form do |f|
    f.inputs do
      f.input :name
      f.input :show_icon
    end
    f.inputs do
      f.input :antennes, label: t('activerecord.attributes.institution.antennes'), as: :ajax_select, data: {
        url: :admin_antennes_path,
        search_fields: [:name],
        limit: 999
      }
    end

    f.actions
  end
end
