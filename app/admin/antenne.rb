# frozen_string_literal: true

ActiveAdmin.register Antenne do
  menu parent: :experts, priority: 1

  controller do
    include SoftDeletable::ActiveAdminResourceController
    def scoped_collection
      # Note: Don’t `includes` lots of related tables, as this causes massive leaks in ActiveAdmin.
      # Preferring N+1 queries fasten x2 index display
      super.includes :institution, :advisors, :experts
    end
  end

  ## Index
  #
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
      if a.managers.any?
        div admin_link_to(a, :managers, list: true)
      else
        div a.manager_full_name
        div a.manager_email
        div a.manager_phone
      end
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
    column(:managers) { |a| a.managers.pluck(:full_name).join(", ") }
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
      row(:nationale)
      row(:community) do |a|
        div admin_link_to(a, :advisors)
        div admin_link_to(a, :experts)
      end
      row(:activity) do |a|
        div admin_link_to(a, :sent_matches)
        div admin_link_to(a, :received_matches)
      end
      row(:manager) do |a|
        if a.managers.any?
          div admin_link_to(a, :managers, list: true)
        else
          div a.manager_full_name
          div a.manager_email
          div a.manager_phone
        end
      end
      row(I18n.t('active_admin.territory.communes_list')) do |a|
        div displays_insee_codes(a.communes)
      end
    end

    attributes_table title: I18n.t('activerecord.attributes.antenne.match_filters') do
      antenne.match_filters.map.with_index do |mf, index|
        panel I18n.t('active_admin.match_filter.title_with_index', index: index + 1) do
          attributes_table_for mf do
            row :min_years_of_existence
            row :effectif_min
            row :effectif_max
            row :subject
            row :raw_accepted_naf_codes
          end
        end
      end
    end
  end

  ## Form
  #
  match_filters_attributes = [ :id, :min_years_of_existence, :effectif_max, :effectif_min, :subject_id, :raw_accepted_naf_codes, :_destroy ]
  permit_params :name, :institution_id, :insee_codes, :manager_full_name, :manager_email, :manager_phone, :nationale,
                advisor_ids: [], expert_ids: [], match_filters_attributes: match_filters_attributes

  form do |f|
    f.inputs do
      f.input :name
      f.input :institution, as: :ajax_select, data: {
        url: :admin_institutions_path,
        search_fields: [:name]
      }
      f.input :insee_codes, as: :text
      f.input :nationale
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

    f.inputs do
      f.has_many :match_filters, allow_destroy: true, new_record: true do |mf|
        mf.input :min_years_of_existence
        mf.input :effectif_min
        mf.input :effectif_max
        if resource.institution.present?
          mf.input :subject, as: :select, collection: resource.institution.subjects.map{ |s| [s.label, s.id] }
        else
          mf.input :subject, as: :ajax_select, data: { url: :admin_subjects_path, search_fields: [:label] }
        end
        mf.input :raw_accepted_naf_codes, as: :text
      end
    end

    f.actions
  end

  ## Actions
  #
  # Delete default destroy action to create a new one with more explicit alert message
  config.action_items.delete_at(2)

  action_item :destroy, only: :show do
    link_to t('active_admin.antenne.delete'), { action: :destroy }, method: :delete, data: { confirm: t('active_admin.antenne.delete_confirmation') }
  end

  batch_action :destroy, confirm: I18n.t('active_admin.antenne.delete_confirmation') do |ids|
    Antenne.where(id: ids).each { |u| u.soft_delete }
    redirect_to collection_path, notice: I18n.t('active_admin.antennes.deleted')
  end
end
