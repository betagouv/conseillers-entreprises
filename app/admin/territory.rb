# frozen_string_literal: true

ActiveAdmin.register Territory do
  menu priority: 8
  permit_params :name, :insee_codes

  includes :communes

  ## index
  #
  filter :name

  scope :all, default: true
  scope I18n.t("active_admin.territory.scopes.bassins_emploi"), :bassins_emploi

  config.sort_order = 'name_asc'

  index do
    selectable_column
    id_column
    column :name
    column :bassin_emploi
    column(:communes) { |territory| territory.communes.size }
  end

  ## Show
  #
  show do
    attributes_table do
      row :name
      row :bassin_emploi
      row(:communes) { |t| safe_join(t.communes.map { |commune| link_to commune, admin_commune_path(commune) }, ', '.html_safe) }
      row(:antennes) { |t| safe_join(t.antennes.distinct.map { |antenne| link_to antenne, admin_antenne_path(antenne) }, ', '.html_safe) }
    end

    render partial: 'admin/users', locals: {
      table_name: I18n.t('activerecord.attributes.territory.relays'),
      users: territory.users
    }

    render partial: 'admin/users', locals: {
      table_name: I18n.t('activerecord.attributes.territory.advisors'),
      users: territory.advisors
    }

    render partial: 'admin/experts', locals: {
      table_name: I18n.t('activerecord.attributes.territory.experts'),
      experts: territory.experts
    }

    render partial: 'admin/matches', locals: { matches: Match.in_territory(territory).ordered_by_date }
  end

  ## Form
  #
  form do |f|
    f.inputs do
      f.input :name
      f.input :bassin_emploi
    end
    f.inputs do
      f.input :insee_codes
    end

    f.actions
  end

  ## Actions
  #
  member_action :assign_entire_territory, method: :post do
    if params[:antenne].present?
      many_communes = Antenne.find(params[:antenne])
    elsif params[:expert].present?
      many_communes = Expert.find(params[:expert])
    end
    many_communes.communes << resource.communes
    redirect_back fallback_location: resource_path, notice: t('active_admin.territory.entire_territory_assigned')
  end
end
