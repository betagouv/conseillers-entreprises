# frozen_string_literal: true

ActiveAdmin.register User do
  menu priority: 2

  permit_params [
    :full_name,
    :email,
    :institution,
    :role,
    :phone_number,
    :is_approved,
    :contact_page_order,
    :contact_page_role,
    :is_admin,
    :password,
    :password_confirmation,
    expert_ids: [],
  ]

  # Index
  #
  index do
    selectable_column
    id_column
    column :full_name
    column :email
    column(:experts) { |user| safe_join(user.experts.map{ |expert| link_to(expert, admin_expert_path(expert)) }, ', '.html_safe) }
    column :created_at
    column :is_approved
    column :sign_in_count
    column(:relays) { |user| user.relays.count }
    actions dropdown: true do |user|
      item t('active_admin.user.impersonate', name: user.full_name), impersonate_engine.impersonate_user_path(user)
    end
  end

  filter :territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }
  filter :full_name
  filter :email
  filter :institution
  filter :role
  filter :phone_number
  filter :is_approved
  filter :is_admin

  # Show
  #
  show do
    attributes_table do
      row :full_name
      row :institution
      row(:experts) { |user| safe_join(user.experts.map{ |expert| link_to(expert, admin_expert_path(expert)) }, ', '.html_safe) }
      row :role
      row :email
      row :phone_number
    end
    attributes_table title: I18n.t('activerecord.models.relay.one') do
      row I18n.t('activerecord.models.territory.other') do |user|
        safe_join(user.territories.map do |territory|
          link_to territory.name, admin_territory_path(territory)
        end, ', '.html_safe)
      end
    end
  end

  sidebar I18n.t('active_admin.user.admin'), only: :show do
    attributes_table_for user do
      row :is_admin
      row :contact_page_order
      row :contact_page_role
    end
  end

  sidebar I18n.t('active_admin.user.connection'), only: :show do
    attributes_table_for user do
      row :created_at
      row :confirmed_at
      row :is_approved
      row :current_sign_in_at
      row :current_sign_in_ip
    end
  end

  action_item :impersonate, only: :show do
    link_to t('active_admin.user.impersonate', name: user.full_name), impersonate_engine.impersonate_user_path(user)
  end

  # Form
  #
  form do |f|
    f.inputs I18n.t('active_admin.user.user_info') do
      f.input :full_name
      f.input :institution
      f.input :experts, as: :ajax_select, data: {
        url: :admin_experts_path,
        search_fields: [:full_name],
        limit: 999,
      }
      f.input :role
      f.input :email
      f.input :phone_number
    end

    f.inputs I18n.t('active_admin.user.connection') do
      f.input :is_approved, as: :boolean
      f.input :password
      f.input :password_confirmation
    end

    f.inputs I18n.t('active_admin.user.admin') do
      f.input :is_admin, as: :boolean
      f.input :contact_page_order
      f.input :contact_page_role
    end

    f.actions
  end

  # Actions
  #
  collection_action :send_invitation_emails, method: :post do
    UserMailer.delay.send_new_user_invitation(params)
    redirect_to admin_dashboard_path, notice: "Utilisateur #{params[:email]} invité."
  end

  controller do
    def update
      send_approval_emails
      update_params_depending_on_password
    end

    def send_approval_emails
      if resource.is_approved? || !params[:user][:is_approved].to_b
        return
      end

      UserMailer.delay.account_approved(resource)
      AdminMailer.delay.new_user_approved_notification(resource, current_user)
    end

    def update_params_depending_on_password
      if params[:user][:password].blank?
        resource.update_without_password(permitted_params.require(:user))
      else
        resource.update(permitted_params.require(:user))
      end
    end
  end
end
