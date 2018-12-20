# frozen_string_literal: true

ActiveAdmin.register User do
  menu priority: 2

  # Index
  #
  includes :antenne, :antenne_institution, :experts, :relay_territories, :searches,
    :sent_diagnoses, :sent_diagnosed_needs, :sent_matches
  config.sort_order = 'created_at_desc'

  scope :all, default: true
  scope :admin
  scope :relays
  scope :without_antenne
  scope :not_approved
  scope :email_not_confirmed

  index do
    selectable_column
    column(:full_name) do |u|
      div admin_link_to(u)
      div '✉ ' + u.email
      div '✆ ' + u.phone_number
      div u.confirmed? ? status_tag('Email ok') : status_tag('Email non confirmé', class: 'warning')
    end
    column :created_at do |u|
      div I18n.l(u.created_at, format: '%Y-%m-%d %H:%M')
      div u.is_approved? ? status_tag('Validé') : status_tag('Compte Non validé', class: 'warning')
    end
    column :role do |u|
      div u.role
      if u.antenne.present?
        div admin_link_to(u, :antenne)
        div admin_link_to(u, :antenne_institution)
      else
        status_tag 'sans antenne', class: 'warning'
        span u.institution
      end
    end
    column(:experts) do |u|
      div admin_link_to(u, :experts, list: true)
      div admin_link_to(u, :relay_territories, list: true)
    end
    column(:activity) do |u|
      div admin_link_to(u, :searches)
      div admin_link_to(u, :sent_diagnoses)
      div admin_link_to(u, :sent_diagnosed_needs)
      div admin_link_to(u, :sent_matches)
    end

    actions dropdown: true do |u|
      if !u.is_approved?
        item(t('active_admin.user.approve_user'), approve_user_admin_user_path(u), method: :post)
      end
      item t('active_admin.user.impersonate', name: u.full_name), impersonate_engine.impersonate_user_path(u)
      item t('active_admin.person.normalize_values'), normalize_values_admin_user_path(u)
    end
  end

  filter :full_name
  filter :email
  filter :role
  filter :antenne, as: :ajax_select, data: { url: :admin_antennes_path, search_fields: [:name] }
  filter :antenne_institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :relay_territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }
  filter :antenne_territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }
  filter :antenne_communes, as: :ajax_select, data: { url: :admin_communes_path, search_fields: [:insee_code] }

  ## CSV
  #
  csv do
    column :full_name
    column :email
    column :phone_number
    column :confirmed?
    column :created_at
    column :is_approved?
    column :role
    column :antenne
    column :antenne_institution do |u|
      u.antenne_institution || "sans antenne: #{u.institution}"
    end
    column_list :experts
    column_list :relay_territories
    column_count :searches
    column_count :sent_diagnoses
    column_count :sent_diagnosed_needs
    column_count :sent_matches
  end

  # Show
  #
  show do
    attributes_table do
      row :full_name
      row :email
      row :phone_number
      row :institution
      row :role do |u|
        div u.role
        if u.antenne.present?
          div admin_link_to(u, :antenne)
          div admin_link_to(u, :antenne_institution)
        else
          status_tag 'sans antenne', class: 'warning'
          span u.institution
        end
      end
      row(:experts) do |u|
        if u.experts.present?
          div admin_link_to(u, :experts, list: true)
        elsif u.corresponding_experts.present?
          text = t('active_admin.user.autolink_to', what: u.corresponding_experts.to_sentence)
          link_to(text, autolink_to_experts_admin_user_path(u), method: :post)
        end
      end
      row :relays_territories do |u|
        div admin_link_to(u, :relay_territories, list: true)
      end
      row :activity do |u|
        div admin_link_to(u, :searches)
        div admin_link_to(u, :sent_diagnoses)
        div admin_link_to(u, :sent_diagnosed_needs)
        div admin_link_to(u, :sent_matches)
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
      row :confirmed?
      row :is_approved
      row :current_sign_in_at
      row :current_sign_in_ip
    end
  end

  action_item :impersonate, only: :show do
    link_to t('active_admin.user.impersonate', name: user.full_name), impersonate_engine.impersonate_user_path(user)
  end

  action_item :normalize_values, only: :show do
    link_to t('active_admin.person.normalize_values'), normalize_values_admin_user_path(user)
  end

  # Form
  #
  permit_params :full_name, :email, :institution, :role, :phone_number, :is_approved,
    :contact_page_order, :contact_page_role,
    :is_admin, :password, :password_confirmation,
    :antenne_id, expert_ids: []

  form do |f|
    f.inputs I18n.t('active_admin.user.user_info') do
      f.input :full_name
      f.input :institution
      f.input :antenne, as: :ajax_select, data: {
        url: :admin_antennes_path,
        search_fields: [:name],
        limit: 999,
      }
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
    redirect_to admin_root_path, notice: "Utilisateur #{params[:email]} invité."
  end

  member_action :approve_user, method: :post do
    resource.update(is_approved: true)
    redirect_back fallback_location: collection_path, notice: t('active_admin.user.approve_user_done')
  end

  member_action :autolink_to_experts, method: :post do
    resource.autolink_experts!
    redirect_back fallback_location: collection_path, notice: I18n.t("active_admin.user.experts_linked")
  end

  member_action :autolink_to_antenne, method: :post do
    resource.autolink_antenne!
    redirect_back fallback_location: collection_path, notice: I18n.t("active_admin.user.antenne_linked")
  end

  member_action :normalize_values do
    resource.normalize_values!
    redirect_back fallback_location: collection_path, notice: t('active_admin.person.normalize_values_done')
  end

  batch_action :destroy, false

  batch_action I18n.t('active_admin.user.autolink_to_experts') do |ids|
    batch_action_collection.find(ids).each { |user| user.autolink_experts! }
    redirect_back fallback_location: collection_path, notice: I18n.t('active_admin.user.experts_linked')
  end

  if Rails.env.development?
    batch_action 'DEBUG: Unlink all experts' do |ids|
      batch_action_collection.find(ids).each do |user|
        if user.experts.present?
          user.experts = []
          user.save!
        end
      end
      redirect_back fallback_location: collection_path, notice: 'All experts were unlinked'
    end
  end

  batch_action I18n.t('active_admin.person.normalize_values') do |ids|
    batch_action_collection.find(ids).each do |user|
      user.normalize_values!
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('active_admin.person.normalize_values_done')
  end

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
        resource.update(permitted_params.require(:user))
      end
    end

    def redirect_or_display_form
      if resource.errors.blank?
        redirect_to resource_path, notice: I18n.t('active_admin.user.saved')
      else
        render :edit
      end
    end
  end
end
