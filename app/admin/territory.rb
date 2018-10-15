# frozen_string_literal: true

ActiveAdmin.register Territory do
  menu priority: 8
  permit_params :name,
    :city_codes,
    territory_cities: %i[id city_code _create _update _destroy]

  ## Show
  #
  show do
    attributes_table do
      row :name
      row :created_at
      row :updated_at
      row(:city_codes) do |territory|
        safe_join(territory.territory_cities.map do |territory_city|
          link_to territory_city.city_code, admin_territory_city_path(territory_city)
        end, ', '.html_safe)
      end
    end

    panel I18n.t('active_admin.territories.experts') do
      table_for territory.experts.includes(:local_office) do
        column :full_name, (proc { |expert| link_to(expert.full_name, admin_expert_path(expert)) })
        column :role
        column :local_office
      end
    end

    render partial: 'admin/matches', locals: { matches_relation: Match.in_territory(territory) }
  end

  sidebar I18n.t('active_admin.territories.relais'), only: :show do
    table_for territory.users do
      column { |user| link_to(user.full_name, admin_user_path(user)) + "<br/> #{user.role}, #{user.institution}".html_safe }
    end
  end

  form do |f|
    f.inputs I18n.t('activerecord.attributes.territory.name') do
      f.input :name
    end

    f.inputs I18n.t('activerecord.attributes.territory_city.city_code') do
      f.input :city_codes
    end

    f.actions
  end

  filter :experts, collection: -> { Expert.ordered_by_names }
  filter :name
  filter :created_at
  filter :updated_at
end
