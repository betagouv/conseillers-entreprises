# frozen_string_literal: true

ActiveAdmin.register Expert do
  menu priority: 6
  includes :institution, :assistances, :territories, :users

  permit_params [
    :full_name,
    :role,
    :institution_id,
    :email,
    :phone_number,
    user_ids: [],
    territory_ids: [],
    assistance_ids: [],
    expert_territories_attributes: %i[id territory_id _create _update _destroy],
    assistances_experts_attributes: %i[id assistance_id _create _update _destroy]
  ]

  # Index
  #
  index do
    selectable_column
    id_column
    column :full_name
    column :institution
    column(:users) { |expert| expert.users.length }
    column :role
    column :email
    column(:assistances) { |expert| expert.assistances.length }
    column(:territories) { |expert| expert.territories.length }
    actions dropdown: true do |expert|
      item t('active_admin.person.normalize_values'), normalize_values_admin_expert_path(expert)
    end
  end

  filter :territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }
  filter :institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :assistances, as: :ajax_select, data: { url: :admin_assistances_path, search_fields: [:title, :description] }
  filter :full_name
  filter :email
  filter :phone_number
  filter :role

  ## Show
  #
  show do
    attributes_table do
      row :full_name
      row :institution
      row :role
      row :email
      row :phone_number
    end
    attributes_table do
      row(:territories) do |expert|
        safe_join(expert.territories.map do |territory|
          link_to territory.name, admin_territory_path(territory)
        end, ', '.html_safe)
      end
    end
    panel I18n.t('activerecord.attributes.expert.assistances') do
      table_for expert.assistances do
        column :question
        column(:title) { |assistance| link_to(assistance.title, admin_assistance_path(assistance)) }
      end
    end

    render partial: 'admin/matches', locals: { matches_relation: Match.of_relay_or_expert(expert) }
  end

  sidebar I18n.t('activerecord.attributes.user.experts'), only: :show do
    table_for expert.users do
      column { |user| link_to(user.full_name, admin_user_path(user)) + "<br/> #{user.role}, #{user.institution}".html_safe }
    end
  end

  sidebar I18n.t('active_admin.experts.access'), only: :show do
    attributes_table do
      row :access_token
    end
  end

  action_item :normalize_values, only: :show do
    link_to t('active_admin.person.normalize_values'), normalize_values_admin_expert_path(expert)
  end

  ## Form
  #
  form do |f|
    f.inputs do
      f.input :full_name
      f.input :institution, as: :ajax_select, data: {
        url: :admin_institutions_path,
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

    f.inputs t('activerecord.attributes.expert.territories') do
      f.input :territories, as: :ajax_select, data: {
        url: :admin_territories_path,
        search_fields: [:name],
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
