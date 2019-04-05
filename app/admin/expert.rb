# frozen_string_literal: true

ActiveAdmin.register Expert do
  menu priority: 4

  # Index
  #
  includes :antenne_institution, :antenne, :users, :skills, :received_matches
  config.sort_order = 'full_name_asc'

  scope :all, default: true
  scope :support_experts
  scope :with_custom_communes, group: :special

  index do
    selectable_column
    column(:full_name) do |e|
      div admin_link_to(e)
      div '➜ ' + e.role
      div '✉ ' + e.email
      div '✆ ' + e.phone_number
    end
    column(:institution) do |e|
      div admin_link_to(e, :antenne_institution)
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
        div admin_link_to(zone, :territories)
        div admin_link_to(zone, :communes)
      end
    end
    column(:users) do |e|
      div admin_link_to(e, :users)
    end
    column(:skills) do |e|
      div admin_link_to(e, :skills)
    end
    column(:received_matches) do |e|
      div admin_link_to(e, :received_matches)
    end
    actions dropdown: true do |expert|
      item t('active_admin.person.normalize_values'), normalize_values_admin_expert_path(expert)
    end
  end

  filter :full_name
  filter :role
  filter :email
  filter :phone_number
  filter :antenne_institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :antenne, as: :ajax_select, data: { url: :admin_antennes_path, search_fields: [:name] }
  filter :antenne_territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }
  filter :antenne_communes, as: :ajax_select, data: { url: :admin_communes_path, search_fields: [:insee_code] }
  filter :skills, as: :ajax_select, data: { url: :admin_skills_path, search_fields: [:title] }

  ## CSV
  #
  csv do
    column :full_name
    column :role
    column :email
    column :phone_number
    column :antenne_institution
    column :antenne
    column_count :antenne_territories
    column_count :antenne_communes
    column :is_global_zone
    column :custom_communes?
    column_count :territories
    column_count :communes
    column_count :users
    column_count :skills
    column_count :received_matches
  end

  ## Show
  #
  show do
    attributes_table do
      row :full_name
      row :access_token
      row :role
      row :email
      row :phone_number
      row :antenne_institution
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
      row(:skills) do |e|
        div admin_link_to(e, :skills, list: true)
      end
      row(:received_matches) do |e|
        div admin_link_to(e, :received_matches)
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
    user_ids: [],
    skill_ids: [],
    experts_skills_attributes: %i[id skill_id _create _update _destroy]
  ]

  form do |f|
    f.inputs do
      f.input :full_name
      f.input :antenne, as: :ajax_select, data: {
        url: :admin_antennes_path,
        search_fields: [:name],
        limit: 999,
      }
      f.input :role
      f.input :email
      f.input :phone_number
    end

    f.inputs t('attributes.custom_communes') do
      f.input :is_global_zone
      f.input :insee_codes
    end

    f.inputs t('activerecord.attributes.expert.users') do
      f.input :users, label: t('activerecord.models.user.other'), as: :ajax_select, data: {
        url: :admin_users_path,
        search_fields: [:full_name],
        limit: 999,
      }
    end

    f.inputs t('activerecord.attributes.expert.skills') do
      collection = option_groups_from_collection_for_select(Subject.all, :skills, :label, :id, :title, expert.skills.pluck(:id))
      f.input :skills, input_html: { :size => 20 }, collection: collection
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
end
