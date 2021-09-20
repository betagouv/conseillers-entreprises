# frozen_string_literal: true

ActiveAdmin.register Expert do
  menu priority: 4

  controller do
    include SoftDeletable::ActiveAdminResourceController
  end

  # Index
  #
  includes :institution, :antenne, :users,
           :communes, :territories, { antenne: [:territories, :communes] },
           :subjects, :received_matches
  config.sort_order = 'full_name_asc'

  scope :active, default: true
  scope :deleted

  scope :support_experts
  scope :with_custom_communes, group: :referencing
  scope :without_subjects, group: :referencing

  scope :teams, group: :members
  scope :personal_skillsets, group: :members
  scope :relevant_for_skills, group: :members
  scope :without_users, group: :members

  index do
    selectable_column
    column(:full_name) do |e|
      div admin_link_to(e)
      unless e.deleted?
        div '➜ ' + (e.role || '')
        div '✉ ' + (e.email || '')
        div '✆ ' + (e.phone_number || '')
      end
    end
    column(:institution) do |e|
      div admin_link_to(e, :institution)
      div admin_link_to(e, :antenne)
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

    column(:flags) do |e|
      e.flags.filter{ |_, v| v.to_b }.map{ |k, _| Expert.human_attribute_name(k) }.to_sentence
    end
  end

  filter :full_name
  filter :role
  filter :email
  filter :phone_number
  filter :institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :antenne, as: :ajax_select, data: { url: :admin_antennes_path, search_fields: [:name] }
  filter :regions, as: :ajax_select, collection: -> { Territory.regions.pluck(:name, :id) },
         data: { url: :admin_territories_path, search_fields: [:name] }
  filter :antenne_territories, as: :ajax_select, collection: -> { Territory.bassins_emploi.pluck(:name, :id) },
         data: { url: :admin_territories_path, search_fields: [:name] }
  filter :antenne_communes, as: :ajax_select, data: { url: :admin_communes_path, search_fields: [:insee_code] }
  filter :subjects, as: :ajax_select, data: { url: :admin_subjects_path, search_fields: [:label] }

  ## CSV
  #
  csv do
    column :full_name
    column :role
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
      row :role
      row :email
      row :phone_number
      row :institution
      row :antenne
      row :reminders_notes
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

      # Dynamically create a status tag for each Expert::FLAGS
      attributes_table title: I18n.t('attributes.flags') do
        Expert::FLAGS.each do |flag|
          row(flag) { |e| status_tag e.send(flag).to_b }
        end
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
  end

  action_item :normalize_values, only: :show do
    link_to t('active_admin.person.normalize_values'), normalize_values_admin_expert_path(expert)
  end

  ## Form
  #
  permit_params [
    :full_name,
    :role,
    :antenne_id,
    :email,
    :phone_number,
    :insee_codes,
    :is_global_zone,
    :reminders_notes,
    *Expert::FLAGS,
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
      f.input :role
      f.input :email
      f.input :phone_number
    end

    f.inputs t('activerecord.attributes.expert.users') do
      f.input :users, label: t('activerecord.models.user.other'),
              as: :ajax_select,
              collection: resource.users,
              data: {
                url: :admin_users_path,
                search_fields: [:full_name],
              }
    end

    f.inputs t('attributes.custom_communes') do
      f.input :is_global_zone
      f.input :insee_codes
    end

    f.inputs I18n.t('attributes.flags') do
      # Dynamically create a checkbox for each Expert::FLAGS
      Expert::FLAGS.each do |flag|
        f.input flag, as: :boolean
      end
    end

    if resource.institution.present?
      f.inputs t('attributes.experts_subjects.other') do
        f.has_many :experts_subjects, allow_destroy: true do |sub_f|
          collection = resource.institution.available_subjects
            .map do |t, s|
              [t.label, s.map { |s| ["#{s.subject.label}: #{s.description}", s.id] }]
            end
            .to_h

          sub_f.input :institution_subject, collection: collection
          sub_f.input :intervention_criteria
        end
      end
    end

    f.inputs do
      f.input :reminders_notes
    end

    f.actions
  end

  ## Actions
  #
  member_action :normalize_values do
    resource.normalize_values!
    redirect_back fallback_location: collection_path, alert: t('active_admin.person.normalize_values_done')
  end

  batch_action I18n.t('active_admin.person.normalize_values') do |ids|
    batch_action_collection.find(ids).each do |expert|
      expert.normalize_values!
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('active_admin.person.normalize_values_done')
  end

  form_options = {
    action: [[I18n.t('active_admin.flag.action.add'), :add], [I18n.t('active_admin.flag.action.remove'), :remove]],
    flag: Expert::FLAGS.map { |f| [Expert.human_attribute_name(f), f] }
  }
  batch_action I18n.t('active_admin.flag.add_remove'), form: form_options do |ids, inputs|
    flag = inputs[:flag]
    value = inputs[:action] == 'add'
    Expert.where(id: ids).each { |u| u.update(flag => value) }

    message = I18n.t("active_admin.flag.done.#{inputs[:action]}", flag: User.human_attribute_name(flag))
    redirect_to collection_path, notice: message
  end
end
