# frozen_string_literal: true

ActiveAdmin.register User do
  menu priority: 1
  permit_params :email, :password, :password_confirmation, :approved

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :approved
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :approved

  form do |f|
    f.inputs I18n.t('active_admin.user.user_info') do
      f.input :first_name
      f.input :last_name
      f.input :email
    end
    f.inputs I18n.t('active_admin.user.user_activation') do
      f.input :approved
    end
    f.actions
  end
end
