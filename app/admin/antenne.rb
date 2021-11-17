# frozen_string_literal: true

ActiveAdmin.register Antenne do
  menu parent: :experts, priority: 1

  controller do
    include SoftDeletable::ActiveAdminResourceController
  end

  ## Index
  #
  includes :institution, :advisors, :experts, :sent_matches, :received_matches,
           :communes, :territories
  config.sort_order = 'name_asc'

  scope :active, default: true
  scope :deleted
  scope :without_communes

  index do
    selectable_column
    column(:name) do |a|
      div admin_link_to(a)
      div admin_link_to(a, :institution)
    end
    column(:community) do |a|
      div admin_link_to(a, :advisors)
      div admin_link_to(a, :experts)
    end
    column(:intervention_zone) do |a|
      div admin_link_to(a, :territories)
      div admin_link_to(a, :communes)
    end
    column(:activity) do |a|
      div admin_link_to(a, :sent_matches, blank_if_empty: true)
      div admin_link_to(a, :received_matches, blank_if_empty: true)
    end
    column(:manager) do |a|
      div a.manager_full_name
      div a.manager_email
      div a.manager_phone
    end
  end

  filter :name
  filter :institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :territories, as: :ajax_select, collection: -> { Territory.bassins_emploi.pluck(:name, :id) },
         data: { url: :admin_territories_path, search_fields: [:name] }
  filter :regions, as: :ajax_select, collection: -> { Territory.regions.pluck(:name, :id) },
         data: { url: :admin_territories_path, search_fields: [:name] }

  filter :communes, as: :ajax_select, data: { url: :admin_communes_path, search_fields: [:insee_code] }

  ## CSV
  #
  csv do
    column :name
    column :institution
    column_count :advisors
    column_count :experts
    column_count :territories
    column_count :communes
    column_count :sent_matches
    column_count :received_matches
  end

  ## Show
  #
  show do
    attributes_table do
      row(:deleted_at) if resource.deleted?
      row :name
      row :institution
      row(:intervention_zone) do |a|
        div admin_link_to(a, :regions)
        div admin_link_to(a, :territories)
        div admin_link_to(a, :communes)
        div intervention_zone_description(a)
      end
      row(:community) do |a|
        div admin_link_to(a, :advisors)
        div admin_link_to(a, :experts)
      end
      row(:activity) do |a|
        div admin_link_to(a, :sent_matches)
        div admin_link_to(a, :received_matches)
      end
      row(:manager) do |a|
        div a.manager_full_name
        div a.manager_email
        div a.manager_phone
      end
      row(I18n.t('active_admin.territory.communes_list')) do |a|
        displays_insee_codes(a.communes)
      end
    end
  end

  ## Form
  #
  permit_params :name, :institution_id, :insee_codes, :manager_full_name, :manager_email, :manager_phone, advisor_ids: [], expert_ids: []

  form do |f|
    f.inputs do
      f.input :name
      f.input :institution, as: :ajax_select, data: {
        url: :admin_institutions_path,
        search_fields: [:name]
      }
      f.input :manager_full_name
      f.input :manager_email
      f.input :manager_phone
      f.input :insee_codes, as: :text
    end

    f.inputs do
      f.input :advisors,
              as: :ajax_select,
              collection: resource.advisors,
              data: {
                url: :admin_users_path,
                search_fields: [:full_name]
              }
    end

    f.inputs do
      f.input :experts,
              as: :ajax_select,
              collection: resource.experts,
              data: {
                url: :admin_experts_path,
                search_fields: [:full_name]
              }
    end

    f.actions
  end
end
