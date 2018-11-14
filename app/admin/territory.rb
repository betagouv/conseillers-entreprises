# frozen_string_literal: true

ActiveAdmin.register Territory do
  menu priority: 8
  permit_params :name, :insee_codes

  includes :users, :advisors, :experts

  ## index
  #
  filter :name
  filter :created_at
  filter :updated_at

  ## Show
  #
  show do
    attributes_table do
      row :name
      row :created_at
      row :updated_at
      row(:communes) { |t| safe_join(t.communes.map { |commune| link_to commune, admin_commune_path(commune) }, ', '.html_safe) }
    end

    render partial: 'admin/antennes', locals: {
      table_name: I18n.t('activerecord.attributes.territory.antennes'),
      antennes: territory.antennes
    }

    render partial: 'admin/users', locals: {
      table_name: I18n.t('activerecord.attributes.territory.relays'),
      users: territory.users.distinct
    }

    render partial: 'admin/users', locals: {
      table_name: I18n.t('activerecord.attributes.territory.advisors'),
      users: territory.advisors.distinct
    }

    render partial: 'admin/experts', locals: {
      table_name: I18n.t('activerecord.attributes.territory.experts'),
      experts: territory.experts.distinct
    }

    render partial: 'admin/matches', locals: { matches: Match.in_territory(territory).ordered_by_status }
  end

  # Form
  #
  form do |f|
    f.inputs I18n.t('activerecord.attributes.territory.name') do
      f.input :name
    end

    f.inputs I18n.t('activerecord.attributes.commune.insee_code') do
      f.input :insee_codes
    end

    f.actions
  end
end
