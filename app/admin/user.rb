# frozen_string_literal: true

ActiveAdmin.register User do
  menu priority: 3

  controller do
    include SoftDeletable::ActiveAdminResourceController
  end

  # Index
  #
  includes :antenne, :institution, :searches, :feedbacks,
           :sent_diagnoses, :sent_needs, :sent_matches,
           :relevant_experts,
           :invitees
  config.sort_order = 'created_at_desc'

  scope :active, default: true
  scope :deleted

  scope :admin

  scope :team_members, group: :teams
  scope :no_team, group: :teams

  scope :never_used, group: :invitations
  scope :invitation_not_accepted, group: :invitations

  index do
    selectable_column
    column(:full_name) do |u|
      div admin_link_to(u)
      unless u.deleted?
        div '✉ ' + u.email
        div '✆ ' + u.phone_number
      end
    end
    column :created_at
    column :role do |u|
      div u.role
      div admin_link_to(u, :antenne)
      div admin_link_to(u, :institution)
    end
    column(:experts) do |u|
      div admin_link_to(u, :relevant_experts, list: true)
    end
    column(:activity) do |u|
      div admin_link_to(u, :searches, blank_if_empty: true)
      div admin_link_to(u, :sent_diagnoses, blank_if_empty: true)
      div admin_link_to(u, :sent_needs, blank_if_empty: true)
      div admin_link_to(u, :sent_matches, blank_if_empty: true)
      div admin_link_to(u, :feedbacks, blank_if_empty: true)
    end

    column(:flags) do |u|
      u.flags.filter{ |_, v| v.to_b }.map{ |k, _| User.human_attribute_name(k) }.to_sentence
    end

    actions dropdown: true do |u|
      item t('active_admin.user.impersonate', name: u.full_name), impersonate_engine.impersonate_user_path(u)
      item t('active_admin.person.normalize_values'), normalize_values_admin_user_path(u)
      item t('active_admin.user.do_invite'), invite_user_admin_user_path(u)
    end
  end

  filter :full_name
  filter :email
  filter :role
  filter :antenne, as: :ajax_select, data: { url: :admin_antennes_path, search_fields: [:name] }
  filter :institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :antenne_territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }
  filter :antenne_communes, as: :ajax_select, data: { url: :admin_communes_path, search_fields: [:insee_code] }

  ## CSV
  #
  csv do
    column :full_name
    column :email
    column :phone_number
    column :created_at
    column :role
    column :antenne
    column :institution
    column_list :experts
    column_count :searches
    column_count :sent_diagnoses
    column_count :sent_needs
    column_count :sent_matches
    column_count :feedbacks
  end

  # Show
  #
  show do
    attributes_table do
      row(:deleted_at) if resource.deleted?
      row :full_name
      row :email
      row :phone_number
      row :institution
      row :role do |u|
        div u.role
        div admin_link_to(u, :antenne)
        div admin_link_to(u, :institution)
      end
      row(:experts) do |u|
        div admin_link_to(u, :experts, list: true)
      end
      row :activity do |u|
        div admin_link_to(u, :searches)
        div admin_link_to(u, :sent_diagnoses)
        div admin_link_to(u, :sent_needs)
        div admin_link_to(u, :sent_matches)
        div admin_link_to(u, :feedbacks)
      end
    end

    # Dynamically create a status tag for each User::FLAGS
    attributes_table title: I18n.t('attributes.flags') do
      User::FLAGS.each do |flag|
        row(flag) { |u| status_tag u.send(flag).to_b }
      end
    end

    attributes_table title: t('activerecord.attributes.user.invitees') do
      row :invitees
    end
  end

  sidebar I18n.t('active_admin.user.admin'), only: :show do
    attributes_table_for user do
      row :is_admin
    end
  end

  sidebar I18n.t('active_admin.user.connection'), only: :show do
    attributes_table_for user do
      row :created_at
      row :inviter
      row :invitation_sent_at
      row :invitation_accepted_at
    end
  end

  action_item :impersonate, only: :show do
    link_to t('active_admin.user.impersonate', name: user.full_name), impersonate_engine.impersonate_user_path(user)
  end

  action_item :normalize_values, only: :show do
    link_to t('active_admin.person.normalize_values'), normalize_values_admin_user_path(user)
  end

  action_item :invite_user, only: :show do
    link_to t('active_admin.user.do_invite'), invite_user_admin_user_path(user)
  end

  # Form
  #
  permit_params :full_name, :email, :institution, :role, :phone_number,
                :is_admin,
                :antenne_id,
                *User::FLAGS,
                expert_ids: []

  form do |f|
    f.inputs I18n.t('active_admin.user.user_info') do
      f.input :full_name
      f.input :antenne, as: :ajax_select,
              collection: [resource.antenne],
              data: {
                url: :admin_antennes_path,
                search_fields: [:name]
              }
      f.input :experts, as: :ajax_select,
              collection: resource.experts,
              data: {
                url: :admin_experts_path,
                search_fields: [:full_name],
                ajax_search_fields: [:antenne_id]
              }
      f.input :role
      f.input :email
      f.input :phone_number
    end

    f.inputs I18n.t('active_admin.user.admin') do
      f.input :is_admin, as: :boolean
    end

    f.inputs I18n.t('attributes.flags') do
      # Dynamically create a checkbox for each User::FLAGS
      User::FLAGS.each do |flag|
        f.input flag, as: :boolean
      end
    end

    f.actions
  end

  # Actions
  #
  member_action :normalize_values do
    resource.normalize_values!
    redirect_back fallback_location: collection_path, notice: t('active_admin.person.normalize_values_done')
  end

  member_action :invite_user do
    resource.invite!(current_user)
    redirect_back fallback_location: collection_path, notice: t('active_admin.user.do_invite_done')
  end

  batch_action I18n.t('active_admin.user.do_invite') do |ids|
    batch_action_collection.find(ids).each do |user|
      user.invite!(current_user)
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('active_admin.user.do_invite_done')
  end

  form_options = {
    action: [[I18n.t('active_admin.flag.action.add'), :add], [I18n.t('active_admin.flag.action.remove'), :remove]],
      flag: User::FLAGS.map { |f| [User.human_attribute_name(f), f] }
  }
  batch_action I18n.t('active_admin.flag.add_remove'), form: form_options do |ids, inputs|
    flag = inputs[:flag]
    value = inputs[:action] == 'add'
    User.where(id: ids).each { |u| u.update(flag => value) }

    message = I18n.t("active_admin.flag.done.#{inputs[:action]}", flag: User.human_attribute_name(flag))
    redirect_to collection_path, notice: message
  end

  controller do
    def update
      resource.update_without_password(permitted_params.require(:user))
      redirect_or_display_form
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
