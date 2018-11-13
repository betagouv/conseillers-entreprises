# frozen_string_literal: true

ActiveAdmin.register Institution do
  menu parent: :experts, priority: 1
  permit_params [
    :name,
    :qualified_for_commerce,
    :qualified_for_artisanry,
    antenne_ids: []
  ]

  includes :antennes, :users, :experts

  ## Index
  #
  filter :name

  config.sort_order = 'name_asc'

  index do
    selectable_column
    id_column
    column :name
    column :antennes, :antennes_count
    column(:experts) { |institution| "#{institution.experts.size}" }
    column(:users) { |institution| "#{institution.users.size}" }
    # The two following lines are actually “N+1 requests” expensive
    # We’ll probably want to remove them or use some counter at some point.
    column(I18n.t('attributes.match_sent.other')) do |institution|
      "#{institution.sent_matches.size}"
    end
    column(I18n.t('attributes.match_received.other')) do |institution|
      "#{institution.received_matches.size}"
    end
  end

  ## Show
  #
  show do
    attributes_table do
      row :name
      row(:antennes) { |t| safe_join(t.antennes.map { |antenne| link_to antenne, admin_antenne_path(antenne) }, ', '.html_safe) }
    end

    render partial: 'admin/users', locals: {
      table_name: I18n.t('activerecord.attributes.institution.users'),
      users: institution.users
    }

    render partial: 'admin/experts', locals: {
      table_name: I18n.t('activerecord.attributes.institution.experts'),
      experts: institution.experts
    }

    render partial: 'admin/matches', locals: {
      table_name: I18n.t('attributes.match_sent', count: institution.sent_matches.size),
      matches: institution.sent_matches
    }

    render partial: 'admin/matches', locals: {
      table_name: I18n.t('attributes.match_received', count: institution.received_matches.size),
      matches: institution.received_matches
    }
  end

  ## Form
  #
  form do |f|
    f.inputs do
      f.input :name
    end
    f.inputs do
      f.input :antennes, label: t('activerecord.attributes.institution.antennes'), as: :ajax_select, data: {
        url: :admin_antennes_path,
        search_fields: [:name],
        limit: 999,
      }
    end

    f.actions
  end
end
