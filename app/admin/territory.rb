# frozen_string_literal: true

ActiveAdmin.register Territory do
  menu priority: 8
  permit_params :name

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
      table_for territory.experts.includes(:institution) do
        column :full_name, (proc { |expert| link_to(expert.full_name, admin_expert_path(expert)) })
        column :role
        column :institution
      end
    end
  end

  filter :experts
  filter :name
  filter :created_at
  filter :updated_at
end
