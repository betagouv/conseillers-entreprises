ActiveAdmin.register Commune do
  menu parent: :territories, priority: 2

  ## Index
  #
  includes :territories, :antennes, :advisors, :antenne_experts
  index do
    selectable_column
    column(:insee_code) do |c|
      div admin_link_to(c)
    end
    column(:territories) do |c|
      div admin_link_to(c, :territories)
    end
    column(:regions) do |c|
      div admin_link_to(c, :regions, list: true)
    end
    column(:community) do |c|
      div admin_link_to(c, :antennes)
      div admin_link_to(c, :advisors)
      div admin_link_to(c, :antenne_experts)
    end
    actions dropdown: true
  end

  filter :insee_code
  filter :regions, as: :ajax_select, collection: -> { Territory.regions.pluck(:name, :id) },
  data: { url: :admin_territories_path, search_fields: [:name] }
  filter :territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }
  filter :antennes, as: :ajax_select, data: { url: :admin_antennes_path, search_fields: [:name] }

  ## CSV
  #
  csv do
    column :insee_code
    column_count :territories
    column_count :antennes
    column_count :advisors
    column_count :antenne_experts
  end

  ## Show
  #
  show do
    attributes_table do
      row :insee_code
      row(:territories) do |c|
        safe_join(c.territories.map { |t| link_to t, admin_territory_path(t) }, ', '.html_safe)
      end
      row(:regions) do |c|
        safe_join(c.regions.map { |t| link_to t, admin_territory_path(t) }, ', '.html_safe)
      end
      row(:antennes) do |c|
        safe_join(c.antennes.map { |a| link_to a, admin_antenne_path(a) }, ', '.html_safe)
      end
      row(:community) do |c|
        div admin_link_to(c, :antennes)
        div admin_link_to(c, :advisors)
        div admin_link_to(c, :antenne_experts)
      end
      row(:direct_experts) do |c|
        div admin_link_to(c, :direct_experts)
      end
    end
  end

  ## Form
  #
  permit_params :insee_code
end
