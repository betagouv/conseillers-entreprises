# frozen_string_literal: true

ActiveAdmin.register Territory do
  menu priority: 8
  permit_params :name,
    :insee_codes

  ## index
  #
  filter :experts, collection: -> { Expert.ordered_by_names }
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
      row(:insee_codes) do |territory|
        safe_join(territory.communes.map do |commune|
          link_to commune, admin_commune_path(commune)
        end, ', '.html_safe)
      end
    end

    panel I18n.t('active_admin.territories.experts') do
      table_for territory.experts.includes(:institution) do
        column :full_name, (proc { |expert| link_to(expert.full_name, admin_expert_path(expert)) })
        column :role
        column :institution
      end
    end

    render partial: 'admin/matches', locals: { matches_relation: Match.in_territory(territory).ordered_by_status }
  end

  sidebar I18n.t('active_admin.territories.relais'), only: :show do
    table_for territory.users do
      column { |user| link_to(user.full_name, admin_user_path(user)) + "<br/> #{user.role}, #{user.institution}".html_safe }
    end
  end

  action_item :convert_to_antenne, only: :show do
    link_to t('active_admin.antenne.create_antenne'), convert_to_antenne_admin_territory_path(resource)
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

  ## Actions
  #
  member_action :convert_to_antenne do
    antenne = Antenne.create_from_territory!(resource)
    redirect_to admin_antenne_path(antenne)
  end
end
