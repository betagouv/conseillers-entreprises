# frozen_string_literal: true

ActiveAdmin.register User do
  menu priority: 1
  permit_params :email, :password, :password_confirmation, :is_approved

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :is_approved
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :is_approved

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
      f.input :is_approved
    end

    f.actions
  end

  controller do
    def update
      update_params_depending_on_password
      redirect_or_display_form
    end

    def update_params_depending_on_password
      @user = User.find(params[:id])
      if params[:user][:password].blank?
        @user.update_without_password(update_without_password)
      else
        @user.update_attributes(update_with_password)
      end
    end

    def redirect_or_display_form
      if @user.errors.blank?
        redirect_to admin_users_path, notice: 'User updated successfully.'
      else
        render :edit
      end
    end

    def update_without_password
      params.require(:user).permit(%i[first_name last_name email institution role phone_number is_approved contact_page_order contact_page_role])
    end

    def update_with_password
      permitted_keys = %i[first_name last_name email institution role phone_number password password_confirmation]
      permitted_keys += %i[is_approved contact_page_order contact_page_role]
      params.require(:user).permit(permitted_keys)
    end
  end
end
