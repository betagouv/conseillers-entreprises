# frozen_string_literal: true

ActiveAdmin.register Expert do
  menu priority: 6
  includes :institution, :assistances, :territories

  permit_params [
    :first_name,
    :last_name,
    :role,
    :institution_id,
    :email,
    :phone_number,
    user_ids: [], # [] means we can pass multiple values to user_ids.
    expert_territories_attributes: %i[id territory_id _create _update _destroy],
    assistances_experts_attributes: %i[id assistance_id _create _update _destroy]
  ]

  # Index
  #
  index do
    selectable_column
    id_column
    column :full_name
    column :last_name
    column :institution
    column(:users) { |expert| expert.users.length }
    column :role
    column :email
    column(:assistances) { |expert| expert.assistances.length }
    column(:territories) { |expert| expert.territories.length }
    actions
  end

  filter :territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }
  filter :institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :assistances, as: :ajax_select, data: { url: :admin_assistances_path, search_fields: [:title, :description] }
  filter :first_name
  filter :last_name
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
        column(:title) { |assistance| link_to(assistance.title, admin_assistance_path(assistance)) }
        column :question
      end
    end
  end

  sidebar I18n.t('activerecord.models.user.other'), only: :show do
    attributes_table do
      row(:users) do |expert|
        safe_join(expert.users.map do |user|
          link_to user.full_name, admin_user_path(user)
        end, ', '.html_safe)
      end
    end
  end

  sidebar I18n.t('active_admin.experts.access'), only: :show do
    attributes_table do
      row :access_token
    end
  end

  ## Form
  #
  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
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
      f.input :assistances, as: :ajax_select, data: {
        url: :admin_assistances_path,
        search_fields: [:title, :description],
        limit: 999,
      }
    end

    f.actions
  end
end
