# frozen_string_literal: true

ActiveAdmin.register Expert do
  menu priority: 6
  includes :institution, :assistances, :users

  permit_params [
    :full_name,
    :role,
    :institution_id,
    :antenne_id,
    :email,
    :phone_number,
    user_ids: [],
    assistance_ids: [],
    assistances_experts_attributes: %i[id assistance_id _create _update _destroy]
  ]

  # Index
  #
  filter :institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :antenne, as: :ajax_select, data: { url: :admin_antennes_path, search_fields: [:name] }
  filter :assistances, as: :ajax_select, data: { url: :admin_assistances_path, search_fields: [:title, :description] }
  filter :full_name
  filter :email
  filter :phone_number
  filter :role

  index do
    selectable_column
    id_column
    column :full_name
    column :institution
    column :antenne
    column :custom_zone?
    column(:users) { |expert| expert.users.size }
    column :role
    column :email
    column(:assistances) { |expert| expert.assistances.size }
    actions dropdown: true do |expert|
      item t('active_admin.person.normalize_values'), normalize_values_admin_expert_path(expert)
    end
  end

  ## Show
  #
  show do
    attributes_table do
      row :full_name
      row :institution
      row :antenne
      row :role
      row :email
      row :phone_number
      row :access_token
    end

    panel I18n.t('activerecord.attributes.expert.assistances') do
      table_for expert.assistances do
        column :question
        column(:title) { |assistance| link_to(assistance.title, admin_assistance_path(assistance)) }
      end
    end

    render partial: 'admin/users', locals: {
      table_name: I18n.t('activerecord.attributes.expert.users'),
      users: expert.users
    }

    render partial: 'admin/matches', locals: { matches: expert.matches }
  end

  action_item :normalize_values, only: :show do
    link_to t('active_admin.person.normalize_values'), normalize_values_admin_expert_path(expert)
  end

  ## Form
  #
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
