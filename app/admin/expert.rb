# frozen_string_literal: true

ActiveAdmin.register Expert do
  menu priority: 4

  controller do
    include SoftDeletable::ActiveAdminResourceController
    include DynamicallyFiltrable
  end

  # Index
  #
  before_action only: :index do
    init_subjects_filter
  end

  includes :institution, :antenne, :users,
           :communes, :territories, { antenne: [:territories, :communes] },
           :subjects, :received_matches
  config.sort_order = 'full_name_asc'

  scope :active, default: true
  scope :deleted
  scope :with_custom_communes

  scope :active_without_users, group: :debug
  scope :active_without_subjects, group: :debug

  index do
    selectable_column
    column(:full_name) do |e|
      div admin_link_to(e)
      unless e.deleted?
        div '➜ ' + (e.job || '')
        div '✉ ' + (e.email || '')
        div '✆ ' + (e.phone_number || '')
      end
    end
    column(:institution_antenne) do |e|
      div admin_link_to(e, :institution)
      div class: 'bold' do
        admin_link_to(e, :antenne)
      end
    end
    column(:intervention_zone) do |e|
      if e.is_global_zone
        status_tag t('activerecord.attributes.expert.is_global_zone'), class: 'yes'
      else
        if e.custom_communes?
          status_tag t('attributes.custom_communes'), class: 'yes'
        end
        zone = e.custom_communes? ? e : e.antenne
        unless e.deleted? || zone.nil?
          div admin_link_to(zone, :territories)
          div admin_link_to(zone, :communes)
        end
      end
    end
    column(:users) do |e|
      div admin_link_to(e, :users)
    end
    column(:subjects) do |e|
      div admin_link_to(e, :subjects)
    end
    column(:activity) do |e|
      div admin_link_to(e, :received_matches, blank_if_empty: true)
    end
  end

  before_action :only => :index do
    @antennes_collection = if params[:q].present? && params[:q][:antenne_institution_id_eq].present?
      Antenne.active.where(institution_id: params[:q][:antenne_institution_id_eq])
    else
      Antenne.active
    end
  end

  filter :full_name
  filter :email
  filter :job
  filter :phone_number
  filter :antenne, as: :ajax_select, collection: -> { @antennes_collection.pluck(:name, :id) }, data: { url: :admin_antennes_path, search_fields: [:name] }
  filter :institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :created_at
  filter :antenne_territorial_level, as: :select, collection: -> { Antenne.human_attribute_values(:territorial_levels, raw_values: true).invert.to_a }
  filter :antenne_regions, as: :select, collection: -> { Territory.regions.order(:name).pluck(:name, :id) }
  filter :antenne_communes, as: :ajax_select, data: { url: :admin_communes_path, search_fields: [:insee_code] }
  filter :themes, as: :select, collection: -> { Theme.order(:label).pluck(:label, :id) }
  filter :subjects, as: :ajax_select, collection: -> { @subjects.pluck(:label, :id) }, data: { url: :admin_subjects_path, search_fields: [:label] }

  ## CSV
  #
  csv do
    column :id
    column :full_name
    column :job
    column :email
    column :phone_number
    column :institution
    column :antenne
    column_count :antenne_territories
    column_count :antenne_communes
    column :is_global_zone
    column :custom_communes?
    column_count :territories
    column_count :communes
    column_count :users
    column_count :subjects
    column_count :received_matches
  end

  ## Show
  #
  show do
    attributes_table do
      row(:deleted_at) if resource.deleted?
      row :full_name
      row :job
      row :email
      row :phone_number
      row :institution
      row :antenne
      row(:intervention_zone) do |e|
        if e.is_global_zone
          status_tag t('activerecord.attributes.expert.is_global_zone'), class: 'yes'
        else
          if e.custom_communes?
            status_tag t('attributes.custom_communes'), class: 'yes'
          end
          div admin_link_to(e, :territories)
          div admin_link_to(e, :communes)
          div intervention_zone_description(e)
        end
      end
      row(:users) do |e|
        div admin_link_to(e, :users)
        div admin_link_to(e, :users, list: true)
      end
      row(:activity) do |e|
        div admin_link_to(e, :received_matches)
      end

      attributes_table title: I18n.t('active_admin.expert.skills') do
        table_for expert.experts_subjects.ordered_for_interview do
          column(:theme)
          column(:subject)
          column(:institution_subject)
          column(:intervention_criteria)
          column(:archived_at) { |es| es.subject.archived_at }
        end
      end

      attributes_table title: I18n.t('active_admin.expert.specifique_zone') do
        row(:intervention_zone) do |e|
          if e.communes.present?
            div displays_insee_codes(e.communes)
          else
            I18n.t('active_admin.expert.no_specifique_zone')
          end
        end
      end
    end
  end

  ## Form
  #
  permit_params [
    :full_name,
    :job,
    :antenne_id,
    :email,
    :phone_number,
    :insee_codes,
    :is_global_zone,
    user_ids: [],
    experts_subjects_ids: [],
    experts_subjects_attributes: %i[id intervention_criteria institution_subject_id _create _update _destroy]
  ]

  form do |f|
    f.inputs do
      f.input :full_name
      f.input :antenne,
              as: :ajax_select,
              collection: [resource.antenne],
              data: {
                url: :admin_antennes_path,
                search_fields: [:name]
              }
      f.input :job
      f.input :email
      f.input :phone_number
    end

    f.inputs t('activerecord.attributes.expert.users.other') do
      f.input :users, label: t('activerecord.models.user.other'),
              as: :ajax_select,
              collection: resource.users,
              data: {
                url: :admin_users_path,
                search_fields: [:full_name],
              }
    end

    f.inputs t('attributes.custom_communes') do
      f.input :insee_codes
    end

    f.inputs t('attributes.is_global_zone') do
      f.input :is_global_zone
    end

    if resource.institution.present?
      f.inputs t('attributes.experts_subjects.other') do
        f.has_many :experts_subjects, allow_destroy: true do |sub_f|
          collection = resource.institution.available_subjects
            .to_h do |t, s|
              [t.label, s.map { |s| ["#{s.subject.label}: #{s.description}", s.id] }]
            end

          sub_f.input :institution_subject, collection: collection
          sub_f.input :intervention_criteria
        end
      end
    end

    f.actions
  end

  ## Actions
  #
  # Delete default destroy action to create a new one with more explicit alert message
  config.action_items.delete_at(2)

  action_item :normalize_values, only: :show do
    link_to t('active_admin.person.normalize_values'), normalize_values_admin_expert_path(expert)
  end

  action_item :destroy, only: :show do
    link_to t('active_admin.expert.delete'), { action: :destroy }, method: :delete, data: { confirm: t('active_admin.expert.delete_confirmation') }
  end

  action_item :deep_soft_delete, only: :show do
    link_to t('active_admin.expert.deep_soft_delete'), { action: :deep_soft_delete }, method: :delete, data: { confirm: t('active_admin.expert.deep_soft_delete_confirmation') }
  end

  member_action :deep_soft_delete, method: :delete do
    resource.deep_soft_delete
    redirect_to collection_path, notice: t('active_admin.person.deep_soft_delete_done')
  end

  member_action :normalize_values do
    resource.normalize_values!
    redirect_back fallback_location: collection_path, notice: t('active_admin.person.normalize_values_done')
  end

  batch_action I18n.t('active_admin.person.normalize_values') do |ids|
    batch_action_collection.find(ids).each do |expert|
      expert.normalize_values!
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('active_admin.person.normalize_values_done')
  end

  batch_action I18n.t('active_admin.expert.deep_soft_delete'), { action: :deep_soft_delete, confirm: I18n.t('active_admin.expert.deep_soft_delete_confirmation') } do |ids|
    Expert.where(id: ids).find_each { |u| u.deep_soft_delete }
    redirect_to collection_path, notice: I18n.t('active_admin.experts.deep_soft_deleted')
  end

  batch_action :destroy, confirm: I18n.t('active_admin.expert.delete_confirmation') do |ids|
    Expert.where(id: ids).find_each { |u| u.soft_delete }
    redirect_to collection_path, notice: I18n.t('active_admin.experts.deleted')
  end
end
