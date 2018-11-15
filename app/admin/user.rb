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
    :antenne_id,
    expert_ids: [],
  ]

  includes :experts, :relays, :territories, :antenne

  # Index
  #
  scope :all, default: true
  scopes = [:admin, :contact_relays, :without_antenne, ]
  scopes.each do |s|
    scope I18n.t("active_admin.user.scopes.#{s}"), s
  end

  filter :full_name
  filter :email
  filter :institution
  filter :role
  filter :confirmed_at_not_null, as: :boolean, label: "Confirmé"
  filter :is_approved
  filter :is_admin

  index do
    selectable_column
    id_column
    column :full_name
    column :email
    column :phone_number
    column(:experts) do |user|
      if user.experts.present?
        safe_join(user.experts.map { |expert| link_to(expert, admin_expert_path(expert)) }, ', '.html_safe)
      elsif user.corresponding_experts.present?
        link_to(t('active_admin.user.autolink_to_experts'), autolink_to_experts_admin_user_path(user), method: :post)
      else
        '-'
      end
    end
    column(:antenne) do |user|
      if user.antenne.present?
        link_to(user.antenne.name, admin_antenne_path(user.antenne))
      else
        '-'
      end
    end
    column(:relays) do |user|
      if user.territories.present?
        safe_join(user.territories.map { |territory| link_to(territory.name, admin_territory_path(territory)) }, ', '.html_safe)
      else
        '-'
      end
    end
    column :created_at
    column :confirmed?
    column :is_approved
    actions dropdown: true do |user|
      if !user.is_approved?
        item(t('active_admin.user.approve_user'), approve_user_admin_user_path(user), method: :post)
      end
      item t('active_admin.user.impersonate', name: user.full_name), impersonate_engine.impersonate_user_path(user)
      if user.experts.empty?
        item(t('active_admin.user.autolink_to_experts'), autolink_to_experts_admin_user_path(user), method: :post)
      end
      item t('active_admin.person.normalize_values'), normalize_values_admin_user_path(user)
    end
  end

  # Show
  #
  show do
    attributes_table do
      row :full_name
      row :institution
      row :antenne
      row(:experts) do |user|
        if user.experts.present?
          safe_join(user.experts.map { |expert| link_to(expert, admin_expert_path(expert)) }, ', '.html_safe)
        elsif user.corresponding_experts.present?
          link_to(t('active_admin.user.autolink_to_experts'), autolink_to_experts_admin_user_path(user), method: :post)
        end
      end
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
    redirect_to resource_path, notice: I18n.t("active_admin.user.expert_linked")
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
