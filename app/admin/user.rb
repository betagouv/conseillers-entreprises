# frozen_string_literal: true

ActiveAdmin.register User do
  menu priority: 2
  permit_params %i[
    first_name last_name email institution role phone_number is_approved contact_page_order contact_page_role
    is_admin password password_confirmation
  ]

  collection_action :send_invitation_emails, method: :post do
    UserMailer.delay.send_new_user_invitation(params)
    redirect_to admin_dashboard_path, notice: "Utilisateur #{params[:email]} invité."
  end

  action_item :impersonate, only: :show do
    link_to('Impersonate', impersonate_engine.impersonate_user_path(user.id))
  end

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :is_approved
    column('Impersonate') { |user| link_to('Impersonate', impersonate_engine.impersonate_user_path(user.id)) }
    actions
  end

  form do |f|
    f.inputs I18n.t('active_admin.user.user_info') do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :institution
      f.input :role
      f.input :phone_number
      f.input :password
      f.input :password_confirmation
      f.input :contact_page_order
      f.input :contact_page_role
    end

    f.inputs I18n.t('active_admin.user.user_activation') do
      f.input :is_approved, as: :boolean
    end

    f.inputs I18n.t('active_admin.user.user_admin') do
      f.input :is_admin, as: :boolean
    end

    f.actions
  end

  filter :first_name
  filter :last_name
  filter :email
  filter :institution
  filter :role
  filter :phone_number
  filter :is_approved
  filter :is_admin
  filter :contact_page_order
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  controller do
    def update
      send_approval_emails
      update_params_depending_on_password
      redirect_or_display_form
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
        resource.update_attributes(permitted_params.require(:user))
      end
    end

    def redirect_or_display_form
      if resource.errors.blank?
        redirect_to admin_users_path, notice: 'User updated successfully.'
      else
        render :edit
      end
    end
  end
end
