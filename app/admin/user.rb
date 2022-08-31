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

  scope :admin, group: :role
  scope :managers, group: :role

  scope :team_members, group: :teams
  scope :no_team, group: :teams

  scope :managers_not_invited, group: :invitations
  scope :not_invited, group: :invitations
  scope :invitation_not_accepted, group: :invitations

  index do
    selectable_column
    column(:full_name) do |u|
      div admin_link_to(u)
      unless u.deleted?
        div '✉ ' + u.email
        div '✆ ' + u.phone_number if u.phone_number
      end
    end
    column :created_at
    column :job do |u|
      div u.job
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

    actions dropdown: true do |u|
      item t('active_admin.user.impersonate', name: u.full_name), impersonate_engine.impersonate_user_path(u)
      item t('active_admin.person.normalize_values'), normalize_values_admin_user_path(u)
      item t('active_admin.user.do_invite'), invite_user_admin_user_path(u)
    end
  end

  filter :full_name
  filter :email
  filter :job
  filter :regions, as: :select, collection: -> { Territory.regions.order(:name).pluck(:name, :id) }
  filter :antenne, as: :ajax_select, data: { url: :admin_antennes_path, search_fields: [:name] }
  filter :institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :antenne_territorial_level, as: :select, collection: -> { Antenne.human_attribute_values(:territorial_levels, raw_values: true).invert.to_a }
  filter :antenne_territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }
  filter :antenne_communes, as: :ajax_select, data: { url: :admin_communes_path, search_fields: [:insee_code] }

  ## CSV
  #
  csv do
    column :full_name
    column :email
    column :phone_number
    column :created_at
    column :job
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
      row :job do |u|
        div u.job
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

    attributes_table title: t('activerecord.attributes.user.invitees') do
      row :invitees
    end
  end

  sidebar I18n.t('active_admin.actions'), only: :show do
    ul class: 'actions' do
      li link_to t('annuaire.users.table.duplicate_user'), admin_user_duplicate_user_path(user), class: 'action'
      li link_to t('annuaire.users.table.reassign_matches'), admin_user_reassign_matches_path(user), class: 'action'
      li link_to t('active_admin.person.normalize_values'), normalize_values_admin_user_path(user), class: 'action'
    end
  end

  sidebar I18n.t('active_admin.user.roles'), only: :show do
    attributes_table do
      if resource.is_admin?
        row :admin do
          div
        end
      end
      resource.managed_antennes.each do |a|
        row :manager do
          a.name
        end
      end
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

  sidebar :invite_user, only: :show do
    link_to t('active_admin.user.do_invite'), invite_user_admin_user_path(user)
  end

  # Form
  #
  user_rights_attributes = [:id, :antenne_id, :category, :_destroy]
  permit_params :full_name, :email, :institution, :job, :phone_number, :antenne_id,
                expert_ids: [], user_rights_attributes: user_rights_attributes

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
      f.input :job
      f.input :email
      f.input :phone_number
    end

    f.inputs I18n.t('active_admin.user.roles') do
      f.has_many :user_rights, allow_destroy: true, new_record: true do |ur|
        ur.input :category, as: :select, collection: UserRight.categories.keys.map{ |cat| [I18n.t(cat, scope: "activerecord.attributes.user_right/categories"), cat] }, include_blank: false
        ur.input :antenne, as: :ajax_select, data: { url: :admin_antennes_path, search_fields: [:name] }
      end
    end

    f.actions
  end

  # Actions
  #
  # Delete default destroy action to create a new one with more explicit alert message
  config.action_items.delete_at(2)

  action_item :destroy, only: :show do
    link_to t('active_admin.user.delete'), { action: :destroy }, method: :delete, data: { confirm: t('active_admin.user.delete_confirmation') }
  end

  action_item :deep_soft_delete, only: :show do
    link_to t('active_admin.user.deep_soft_delete'), { action: :deep_soft_delete }, method: :delete, data: { confirm: t('active_admin.user.deep_soft_delete_confirmation') }
  end

  member_action :deep_soft_delete, method: :delete do
    resource.deep_soft_delete
    redirect_to collection_path, notice: t('active_admin.person.deep_soft_delete_done')
  end

  member_action :normalize_values do
    resource.normalize_values!
    redirect_back fallback_location: collection_path, notice: t('active_admin.person.normalize_values_done')
  end

  member_action :invite_user do
    resource.invite!(current_user) unless resource.deleted?
    redirect_back fallback_location: collection_path, notice: t('active_admin.user.do_invite_done')
  end

  batch_action I18n.t('active_admin.user.do_invite') do |ids|
    batch_action_collection.find(ids).each do |user|
      user.invite!(current_user) unless user.deleted?
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('active_admin.user.do_invite_done')
  end

  batch_action :destroy, confirm: I18n.t('active_admin.users.delete_confirmation') do |ids|
    User.where(id: ids).each { |u| u.soft_delete }
    redirect_to collection_path, notice: I18n.t('active_admin.user.deleted')
  end

  batch_action I18n.t('active_admin.user.deep_soft_delete'), { action: :deep_soft_delete, confirm: I18n.t('active_admin.user.deep_soft_delete_confirmation') } do |ids|
    User.where(id: ids).each { |u| u.deep_soft_delete }
    redirect_to collection_path, notice: I18n.t('active_admin.users.deep_soft_deleted')
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
