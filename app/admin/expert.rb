ActiveAdmin.register Expert do
  menu priority: 4

  controller do
    include SoftDeletable::ActiveAdminResourceController
    include DynamicallyFiltrable

    helper ActiveAdminUtilitiesHelper

    def scoped_collection
      base_includes = [:antenne, :institution]
      additional_includes = []

      case params[:scope]
      when 'without_users', 'active_without_users'
        # These scopes already use LEFT JOIN, no need for includes on users
        additional_includes += [:subjects, :received_matches, :match_filters]
      when 'active_without_subjects', 'active_with_matches_and_without_subjects'
        # These scopes use where.missing or left_joins
        additional_includes += [:users, :received_matches, :match_filters]
      when 'with_territorial_zones', 'active', nil
        # This scope uses EXISTS, add zone associations
        additional_includes += [:users, :subjects, :received_matches, :match_filters]
      when 'deleted'
        # For deleted experts, only load minimum
        additional_includes += [:users, :subjects]
      end

      # Optimize based on active filters
      if params.dig(:q, :antenne_id_eq).present? || params.dig(:q, :antenne_regions_id_eq).present?
        additional_includes += [:antenne]
      end

      if params.dig(:q, :institution_id_eq).present?
        additional_includes += [:institution]
      end

      if params.dig(:q, :themes_id_eq).present? || params.dig(:q, :subjects_id_eq).present?
        additional_includes += [:subjects, { subjects: :theme }]
      end

      includes = base_includes + additional_includes
      super.includes(includes.uniq)
    end

    def create
      create! do |success, failure|
        success.html do
          if params[:save_and_edit]
            redirect_to edit_admin_expert_path(resource)
          else
            redirect_to admin_expert_path(resource)
          end
        end
      end
    end

    def destroy
      super(location: resource_path(resource)) # Redirect to the show page after a soft-delete
    end
  end

  # Index
  #
  before_action only: :index do
    init_subjects_filter
  end

  config.sort_order = 'full_name_asc'

  scope :active, default: true
  scope :deleted
  scope :with_territorial_zones

  scope :without_users, group: :debug
  scope :active_without_users, group: :debug
  scope :active_with_matches_and_without_subjects, group: :debug
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
    column(:territoral_zone) do |expert|
      territorial_zone_column_content(expert)
    end

    column(:users) do |e|
      div admin_link_to(e, :users)
    end
    column(:subjects) do |e|
      div admin_link_to(e, :subjects)
    end
    column(:activity) do |e|
      div admin_link_to(e, :received_matches, blank_if_empty: true)
      admin_link_to_expert_shared_satisfaction(e)
    end
    column(:filters) do |i|
      div i.match_filters.count if i.match_filters.any?
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
  filter :regions, as: :select, collection: -> { RegionOrderingService.call.map { |r| [r.nom, r.code] } }
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
    column :is_global_zone
    column_count :territorial_zones
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
        end
      end
      row(:users) do |e|
        div admin_link_to(e, :users)
        div admin_link_to(e, :users, list: true)
      end
      row(:activity) do |e|
        div admin_link_to(e, :received_matches)
        admin_link_to_expert_shared_satisfaction(e)
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
    end

    panel I18n.t('activerecord.models.territorial_zone.other') do
      if expert.territorial_zones.any?
        TerritorialZone.zone_types.keys.reverse_each do |zone_type|
          expert_territorial_zones = expert.territorial_zones.select { |tz| tz.zone_type == zone_type }
          next if expert_territorial_zones.empty?
          attributes_table title: I18n.t(zone_type, scope: "activerecord.attributes.territorial_zone").pluralize do
            model = DecoupageAdministratif.const_get(zone_type.camelize)
            expert_territorial_zones.map do |tz|
              row(tz.code) do
                model_instance = model.find(tz.code)
                name = model_instance.nom
                if zone_type == "epci"
                  communes_names = []
                  model_instance.communes.sort_by(&:nom).map do |commune|
                    communes_names << "#{commune.nom} (#{commune.code})"
                  end
                  name = "<b>" + name + "</b><br/>" + communes_names.join(', ')
                end
                name.html_safe
              end
            end
          end
        end
      else
        I18n.t('active_admin.expert.no_specifique_zone')
      end
    end

    attributes_table title: I18n.t('active_admin.antenne.institution_match_filters') do
      expert.institution.match_filters.map.with_index do |mf, index|
        panel I18n.t('active_admin.match_filter.title_with_index', index: index + 1) do
          attributes_table_for mf do
            format_match_filter_attributes(mf).each do |filter, content|
              row(filter) { content }
            end
          end
        end
      end
    end

    attributes_table title: I18n.t('active_admin.antenne.match_filters') do
      expert.antenne.match_filters.map.with_index do |mf, index|
        panel I18n.t('active_admin.match_filter.title_with_index', index: index + 1) do
          attributes_table_for mf do
            format_match_filter_attributes(mf).each do |filter, content|
              row(filter) { content }
            end
          end
        end
      end
    end

    attributes_table title: I18n.t('active_admin.expert.match_filters') do
      expert.match_filters.map.with_index do |mf, index|
        panel I18n.t('active_admin.match_filter.title_with_index', index: index + 1) do
          attributes_table_for mf do
            format_match_filter_attributes(mf).each do |filter, content|
              row(filter) { content }
            end
          end
        end
      end
    end
  end

  sidebar I18n.t('active_admin.actions'), only: :show do
    ul class: 'actions' do
      unless resource.deleted?
        li link_to t('annuaire.users.table.reassign_matches'), admin_expert_reassign_matches_path(expert), class: 'action'
      end
    end
  end

  sidebar I18n.t('attributes.created_at'), only: :show do
    attributes_table_for expert do
      row :created_at
    end
  end

  ## Form
  #
  match_filters_attributes = [
    :id, :min_years_of_existence, :max_years_of_existence, :effectif_max, :effectif_min,
    :raw_accepted_naf_codes, :raw_excluded_naf_codes, :raw_accepted_legal_forms, :raw_excluded_legal_forms, :_destroy, subject_ids: []
  ]
  permit_params [
    :full_name,
    :job,
    :antenne_id,
    :email,
    :phone_number,
    :is_global_zone,
    user_ids: [],
    experts_subjects_ids: [],
    experts_subjects_attributes: %i[id intervention_criteria institution_subject_id _create _update _destroy],
    match_filters_attributes: match_filters_attributes,
    territorial_zones_attributes: [:id, :zone_type, :code, :_destroy]
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

    f.inputs t('attributes.is_global_zone') do
      f.input :is_global_zone
    end

    f.inputs do
      f.has_many :territorial_zones, allow_destroy: true, new_record: true do |tz|
        tz.input :zone_type,
                 collection: TerritorialZone.zone_types.keys.map { |k| [I18n.t(k, scope: 'activerecord.attributes.territorial_zone'), k] },
                 as: :select
        tz.input :code,
                 as: :ajax_select,
                 collection: tz.object.persisted? ? [[tz.object.name + " (" + tz.object.code + ")", tz.object.code]] : [], data: {
                   url: :admin_territorial_zones_search_path,
            search_fields: [:nom],
            limit: 10,
                 }
      end
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

    f.inputs do
      f.has_many :match_filters, allow_destroy: true, new_record: true do |mf|
        if resource.institution.present?
          mf.input :subjects, as: :ajax_select, collection: resource.institution.subjects, data: { url: :admin_subjects_path, search_fields: [:label] }
        else
          mf.input :subjects, as: :ajax_select, data: { url: :admin_subjects_path, search_fields: [:label] }
        end
        mf.input :min_years_of_existence
        mf.input :max_years_of_existence
        mf.input :effectif_min
        mf.input :effectif_max
        mf.input :raw_accepted_legal_forms
        mf.input :raw_excluded_legal_forms
        mf.input :raw_accepted_naf_codes, as: :text
        mf.input :raw_excluded_naf_codes, as: :text
      end
    end

    f.actions do
      if resource.persisted?
        f.actions
      else
        f.action :submit, label: t('active_admin.save')
        f.action :submit, label: 'Save and Edit', button_html: { name: 'save_and_edit', value: I18n.t('active_admin.save_and_edit') }
        f.action :cancel, wrapper_html: { class: 'cancel' }
      end
    end
  end

  ## Actions
  #
  # Delete default destroy action to create a new one with more explicit alert message
  config.action_items.delete_at(2)

  action_item :normalize_values, only: :show do
    link_to t('active_admin.person.normalize_values'), normalize_values_admin_expert_path(expert)
  end

  action_item :destroy, only: :show do
    link_to t('active_admin.expert.delete'), { action: :destroy }, method: :delete, data: { confirm: t('active_admin.expert.delete_confirmation', count: 1) }
  end

  member_action :normalize_values do
    resource.normalize_values!
    redirect_back_or_to collection_path, notice: t('active_admin.person.normalize_values_done')
  end

  batch_action I18n.t('active_admin.person.normalize_values') do |ids|
    batch_action_collection.find(ids).each do |expert|
      expert.normalize_values!
    end
    redirect_back_or_to collection_path, notice: I18n.t('active_admin.person.normalize_values_done')
  end

  batch_action :destroy, confirm: I18n.t('active_admin.expert.delete_confirmation', count: 2) do |ids|
    Expert.where(id: ids).destroy_all
    redirect_to collection_path, notice: I18n.t('active_admin.experts.deleted')
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_back_or_to collection_path, alert: e.record.errors.full_messages.join(". ")
  end
end
