# frozen_string_literal: true

ActiveAdmin.register Expert do
  menu priority: 6

  # Index
  #
  includes :antenne_institution, :antenne, :communes, :territories, :users, :assistances
  includes antenne: [:communes, :territories]
  config.sort_order = 'full_name_asc'

  scope :all, default: true
  scope I18n.t("active_admin.experts.scopes.with_custom_communes"), :with_custom_communes

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
      if e.custom_communes?
        status_tag t('attributes.custom_communes'), class: 'yes'
      end
      zone = e.custom_communes? ? e : e.antenne
      div admin_link_to(zone, :territories)
      div admin_link_to(zone, :communes)
    end
    column(:users) do |e|
      div admin_link_to(e, :users)
    end
    column(:assistances) do |e|
      div admin_link_to(e, :assistances)
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
  filter :assistances, as: :ajax_select, data: { url: :admin_assistances_path, search_fields: [:title] }

  ## Show
  #
  show do
    attributes_table do
      row :full_name
      row :role
      row :email
      row :phone_number
      row :antenne_institution
      row :antenne
      row(:intervention_zone) do |e|
        if e.custom_communes?
          status_tag t('attributes.custom_communes'), class: 'yes'
        end
        div admin_link_to(e, :territories)
        div admin_link_to(e, :communes)
        div intervention_zone_description(e)
      end
      row(:assistances) do |e|
        div admin_link_to(e, :assistances)
      end
      row :access_token
    end

    render partial: 'admin/users', locals: {
      table_name: I18n.t('activerecord.attributes.expert.users'),
      users: expert.users
    }

    render partial: 'admin/matches', locals: { matches: expert.received_matches }
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
    user_ids: [],
    assistance_ids: [],
    assistances_experts_attributes: %i[id assistance_id _create _update _destroy]
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
      f.input :insee_codes
    end

    f.inputs t('activerecord.attributes.expert.users') do
      f.input :users, label: t('activerecord.models.user.other'), as: :ajax_select, data: {
        url: :admin_users_path,
        search_fields: [:full_name],
        limit: 999,
      }
    end

    f.inputs t('activerecord.attributes.expert.assistances') do
      collection = option_groups_from_collection_for_select(Question.all, :assistances, :label, :id, :title, expert.assistances.pluck(:id))
      f.input :assistances, input_html: { :size => 20 }, collection: collection
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
