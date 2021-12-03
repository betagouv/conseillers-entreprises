# frozen_string_literal: true

ActiveAdmin.register Territory do
  menu priority: 5

  ## index
  #
  # Note: Don’t `includes` related tables, as this causes massive leaks in ActiveAdmin.
  # Since we only have a few dozens entries, N+1 queries are preferred.
  config.sort_order = 'name_asc'

  scope :all, default: true
  scope :bassins_emploi
  scope :regions

  index do
    selectable_column
    column(:name) do |t|
      div admin_link_to(t)
      if t.bassin_emploi
        div status_tag :bassin_emploi, class: 'ok'
      end
      if t.code_region
        div status_tag :region, class: 'ok'
      end
    end
    column(:communes) do |t|
      div admin_link_to(t, :communes)
    end
    column(:community) do |t|
      div admin_link_to(t, :antennes)
      div admin_link_to(t, :advisors)
      div admin_link_to(t, :antenne_experts)
    end
    column(:activity) do |c|
      div admin_link_to(c, :diagnoses, blank_if_empty: true)
      div admin_link_to(c, :needs, blank_if_empty: true)
      div admin_link_to(c, :matches, blank_if_empty: true)
    end
  end

  filter :name
  filter :communes, as: :ajax_select, data: { url: :admin_communes_path, search_fields: [:insee_code] }

  ## CSV
  #
  csv do
    column :name
    column :bassin_emploi
    column :code_region
    column_count :communes
    column_count :antennes
    column_count :advisors
    column_count :antenne_experts
    column_count :diagnoses
    column_count :needs
    column_count :matches
  end

  ## Show
  #
  show do
    attributes_table do
      row :name
      row :bassin_emploi
      row :code_region do |t|
        div I18n.t(t.code_region, scope: 'regions_codes_to_libelles', default: "")
        div t.code_region
      end
      row :support_contact
      row :deployed_at do |t|
        div t.deployed_at&.to_date
      end
      row(:communes) do |t|
        div admin_link_to(t, :communes)
        div displays_insee_codes(t.communes)
      end
      row(:antennes) do |t|
        div admin_link_to(t, :antennes)
        div safe_join(t.antennes.distinct.map { |a| admin_link_to a }, ', '.html_safe)
      end
      row(:community) do |t|
        div admin_link_to(t, :advisors)
        div admin_link_to(t, :antenne_experts)
      end
      row(:activity) do |c|
        div admin_link_to(c, :diagnoses)
        div admin_link_to(c, :needs)
        div admin_link_to(c, :matches)
      end
    end
  end

  ## Form
  #
  permit_params :name, :insee_codes, :bassin_emploi, :code_region, :support_contact_id

  form do |f|
    f.inputs do
      f.input :name
      f.input :bassin_emploi
      f.input :code_region, as: :select, collection: regions_list.map{ |r| [r.last, r.first] }
      f.input :support_contact, collection: User.admin.not_deleted
    end
    f.inputs do
      f.input :insee_codes, as: :text
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
