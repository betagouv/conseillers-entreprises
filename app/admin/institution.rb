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
    end

    render partial: 'admin/users', locals: {
      table_name: I18n.t('attributes.advisors', count: institution.advisors.size),
      users: institution.advisors
    }

    render partial: 'admin/experts', locals: {
      table_name: I18n.t('attributes.experts', count: institution.experts.size),
      experts: institution.experts
    }

    render partial: 'admin/matches', locals: {
      table_name: I18n.t('attributes.sent_matches', count: institution.sent_matches.size),
      matches: institution.sent_matches
    }

    render partial: 'admin/matches', locals: {
      table_name: I18n.t('attributes.received_matches', count: institution.received_matches.size),
      matches: institution.received_matches
    }
  end

  ## Form
  #
  permit_params :name, :qualified_for_commerce, :qualified_for_artisanry, antenne_ids: []

  form do |f|
    f.inputs do
      f.input :name
    end
    f.inputs do
      f.input :antennes, label: t('activerecord.attributes.institution.antennes'), as: :ajax_select, data: {
        url: :admin_antennes_path,
        search_fields: [:name]
      }
    end

    f.actions
  end
end
