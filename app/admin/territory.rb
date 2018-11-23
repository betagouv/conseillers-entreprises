# frozen_string_literal: true

ActiveAdmin.register Territory do
  menu priority: 8

  ## index
  #
  includes :communes, :relay_users, :antennes, :advisors, :antenne_experts, :diagnoses, :diagnosed_needs, :matches
  config.sort_order = 'name_asc'

  scope :all, default: true
  scope I18n.t("active_admin.territory.scopes.bassins_emploi"), :bassins_emploi

  index do
    selectable_column
    column(:name) do |t|
      div admin_link_to(t)
      if t.bassin_emploi
        div status_tag :bassin_emploi, class: 'ok'
      end
    end
    column(:communes) do |t|
      div admin_link_to(t, :communes)
    end
    column(:community) do |t|
      div admin_link_to(t, :relay_users)
      div admin_link_to(t, :antennes)
      div admin_link_to(t, :advisors)
      div admin_link_to(t, :antenne_experts)
    end
    column(:activity) do |c|
      div admin_link_to(c, :diagnoses)
      div admin_link_to(c, :diagnosed_needs)
      div admin_link_to(c, :matches)
    end
  end

  filter :name
  filter :communes, as: :ajax_select, data: { url: :admin_communes_path, search_fields: [:insee_code] }

  ## CSV
  #
  csv do
    column :name
    column :bassin_emploi
    column_count :communes
    column_list :relays
    column_count :antennes
    column_count :advisors
    column_count :antenne_experts
    column_count :diagnoses
    column_count :diagnosed_needs
    column_count :matches
  end

  ## Show
  #
  show do
    attributes_table do
      row :name
      row :bassin_emploi
      row(:communes) do |t|
        div admin_link_to(t, :communes)
        safe_join(t.communes.map { |c| admin_link_to c }, ', '.html_safe)
      end
      row(:antennes) do |t|
        safe_join(t.antennes.distinct.map { |a| admin_link_to a }, ', '.html_safe)
      end
      row(:community) do |t|
        div admin_link_to(t, :relay_users)
        div admin_link_to(t, :antennes)
        div admin_link_to(t, :advisors)
        div admin_link_to(t, :antenne_experts)
      end
      row(:activity) do |c|
        div admin_link_to(c, :diagnoses)
        div admin_link_to(c, :diagnosed_needs)
        div admin_link_to(c, :matches)
      end
    end

    render partial: 'admin/users', locals: {
      table_name: I18n.t('activerecord.attributes.territory.relays'),
      users: territory.relay_users
    }

    render partial: 'admin/users', locals: {
      table_name: I18n.t('activerecord.attributes.territory.advisors'),
      users: territory.advisors
    }

    render partial: 'admin/experts', locals: {
      table_name: I18n.t('activerecord.attributes.territory.experts'),
      experts: territory.antenne_experts
    }

    render partial: 'admin/matches', locals: { matches: Match.in_territory(territory).ordered_by_date }
  end

  ## Form
  #
  permit_params :name, :insee_codes

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
