ActiveAdmin.register User do
  menu priority: 3

  controller do
    include SoftDeletable::ActiveAdminResourceController

    def scoped_collection
      base_includes = [:antenne, :institution]
      additional_includes = []

      # If using role scopes, include user_rights
      if params[:scope].in?(['admin', 'managers', 'cooperation_managers', 'managers_not_invited'])
        additional_includes << :user_rights
      end

      # If displaying activity information (default on index)
      if params[:scope].blank? || params[:scope] == 'active'
        additional_includes += [:feedbacks, :sent_diagnoses, :sent_needs, :sent_matches, :invitees]
      end

      # Optimize based on active filters
      if params.dig(:q, :antenne_id_eq).present? || params.dig(:q, :antenne_regions_id_eq).present?
        additional_includes += [:antenne, { antenne: :territorial_zones }]
      end

      if params.dig(:q, :institution_id_eq).present?
        additional_includes += [:institution]
      end

      # If filtering by experts, include expert associations
      if params.dig(:q, :experts_id_eq).present?
        additional_includes += [:experts]
      end

      includes = base_includes + additional_includes
      super.includes(includes.uniq)
    end
  end

  # Index
  #
  config.sort_order = 'created_at_desc'

  scope I18n.t("active_admin.user.active"), :active, default: true
  scope :without_activity
  scope :currently_absent
  scope :deleted

  scope :admin, group: :role
  scope :managers, group: :role
  scope :cooperation_managers, group: :role

  scope :managers_not_invited, group: :invitations
  scope :not_invited, group: :invitations
  scope :recent_active_invitation_not_accepted, group: :invitations
  scope :old_active_invitation_not_accepted, group: :invitations

  index do
    selectable_column
    column(:full_name) do |u|
      div admin_link_to(u)
      unless u.deleted?
        div '✉ ' + u.email
        div '✆ ' + u.phone_number if u.phone_number
      end
      if u.absence_end_at && u.absence_end_at >= Time.current && u.absence_start_at <= Time.current
        status_tag t('attributes.absent_until', date: I18n.l(u.absence_end_at, format: :sentence)), class: 'warning'
      elsif u.absence_end_at && u.absence_end_at >= Time.current && u.absence_start_at > Time.current
        status_tag t('attributes.absent_between', start_date: I18n.l(u.absence_start_at, format: :short_sentence), end_date: I18n.l(u.absence_end_at, format: :short_sentence)), class: 'info'
      end
    end
    column :created_at
    column :job do |u|
      div u.job
      div admin_link_to(u, :antenne)
      div admin_link_to(u, :institution)
    end
    column(:experts) do |u|
      div admin_link_to(u, :experts, list: true)
    end
    column(:activity) do |u|
      div admin_link_to(u, :activity_matches)
      div admin_link_to(u, :feedbacks)
    end

    actions dropdown: true do |u|
      item t('active_admin.user.impersonate', name: u.full_name), impersonate_engine.impersonate_user_path(u)
      item t('active_admin.person.normalize_values'), normalize_values_admin_user_path(u)
      item t('active_admin.user.do_invite'), invite_user_admin_user_path(u)
      item(t('active_admin.user.invite_to_demo'), invite_to_demo_admin_user_path(u)) if u.first_expert_with_subject.present?
    end
  end

  filter :full_name
  filter :email
  filter :job
  filter :antenne, as: :ajax_select, data: { url: :admin_antennes_path, search_fields: [:name] }
  filter :institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :region, as: :select, collection: -> { RegionOrderingService.call.map { |r| [r.nom, r.code] } }
  filter :created_at
  filter :antenne_territorial_level, as: :select, collection: -> { Antenne.human_attribute_values(:territorial_levels, raw_values: true).invert.to_a }

  ## CSV
  #
  csv do
    column :id
    column :full_name
    column :email
    column :phone_number
    column :created_at
    column :job
    column :antenne
    column :institution
    column_list :experts
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
      if resource.absence_start_at
        row :absence_start_at do
          I18n.l(resource.absence_start_at, format: :sentence)
        end
      end
      if resource.absence_end_at
        row :absence_end_at do
          I18n.l(resource.absence_end_at, format: :sentence)
        end
      end
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
        div admin_link_to(u, :sent_diagnoses)
        div admin_link_to(u, :sent_needs)
        div admin_link_to(u, :sent_matches)
        div admin_link_to(u, :feedbacks)
      end
    end
  end

  sidebar I18n.t('active_admin.actions'), only: :show do
    ul class: 'actions' do
      unless resource.deleted?
        li link_to t('annuaire.users.table.duplicate_user'), admin_user_duplicate_user_path(user), class: 'action'
      end
      li link_to t('active_admin.person.normalize_values'), normalize_values_admin_user_path(user), class: 'action'
      li link_to t('active_admin.user.create_expert'), create_expert_admin_user_path(user), class: 'action'
    end
  end

  sidebar I18n.t('active_admin.user.roles'), only: :show do
    attributes_table do
      ul do
        resource.user_rights.each do |ur|
          li do
            right = I18n.t(ur.category, scope: "activerecord.attributes.user_right/categories")
            if ur.rightable_element.present? && !ur.rightable_element.is_a?(TerritorialZone)
              right = "#{right} : #{admin_link_to(ur.rightable_element)}".html_safe
            elsif ur.rightable_element.is_a?(TerritorialZone)
              right = "#{right} : #{ur.rightable_element.name}"
            else
              right
            end
          end
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
      row :demo_invited_at
    end
  end

  sidebar I18n.t('active_admin.user.send_emails'), only: :show do
    ul class: 'actions' do
      li link_to t('active_admin.user.do_invite'), invite_user_admin_user_path(user), class: 'action'
      li link_to t('active_admin.user.invite_to_demo'), invite_to_demo_admin_user_path(user), class: 'action'
      li link_to t('active_admin.user.do_reset_password'), reset_password_admin_user_path(user), class: 'action'
    end
  end

  action_item :impersonate, only: :show do
    link_to t('active_admin.user.impersonate', name: user.full_name), impersonate_engine.impersonate_user_path(user)
  end

  # Form
  #
  user_rights_attributes = [:id, :rightable_element_id, :rightable_element_type, :category, :_destroy]
  permit_params :full_name, :email, :institution, :job, :phone_number, :antenne_id, :create_expert, :absence_start_at, :absence_end_at,
                expert_ids: [], user_rights_attributes: user_rights_attributes, user_rights_for_admin_attributes: user_rights_attributes,
                user_rights_manager_attributes: user_rights_attributes, user_rights_cooperation_manager_attributes: user_rights_attributes,
                user_rights_territorial_referent_attributes: user_rights_attributes

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs I18n.t('active_admin.user.user_info') do
      f.input :full_name
      f.input :antenne, as: :ajax_select,
              collection: [resource.antenne],
              data: {
                url: :admin_antennes_path,
                search_fields: [:name]
              }
      f.input :experts, as: :ajax_select,
              collection: resource&.antenne&.experts,
              data: {
                url: :admin_experts_path,
                search_fields: [:full_name],
                ajax_search_fields: [:antenne_id]
              }
      f.input :job
      f.input :email
      f.input :phone_number
    end

    f.inputs I18n.t('active_admin.user.absence') do
      f.input :absence_start_at, as: :datepicker, datepicker_options: { min_date: Date.today }
      f.input :absence_end_at, as: :datepicker, datepicker_options: { min_date: Date.today }
    end

    f.inputs I18n.t('active_admin.user.roles') do
      # Droits responsables d'antenne
      label_base = t('activerecord.models.user_right.manager')
      f.has_many :user_rights_manager, heading: label_base[:other], allow_destroy: true, new_record: t('active_admin.has_many_new', model: label_base[:one]) do |ur|
        ur.input :category, as: :hidden, input_html: { value: 'manager' }
        ur.input :antenne,
                 collection: [[resource.antenne&.name, resource.antenne&.id]],
                 as: :ajax_select,
                 data: {
                   url: :admin_antennes_path,
                   search_fields: [:name]
                 }
        ur.input :rightable_element_type, as: :hidden, input_html: { value: 'Antenne' }
      end

      # Droits responsables de coopération
      label_base = t('activerecord.models.user_right.cooperation_manager')
      f.has_many :user_rights_cooperation_manager, heading: label_base[:other], allow_destroy: true, new_record: t('active_admin.has_many_new', model: label_base[:one]) do |ur|
        ur.input :category, as: :hidden, input_html: { value: 'cooperation_manager' }
        ur.input :cooperation,
                 collection: Cooperation.not_archived.pluck(:name, :id),
                 as: :ajax_select,
                 data: {
                   url: :admin_cooperations_path,
                   search_fields: [:name]
                 }
        ur.input :rightable_element_type, as: :hidden, input_html: { value: 'Cooperation' }
      end

      # Droits référent de region
      label_base = t('activerecord.models.user_right.territorial_referent')
      f.has_many :user_rights_territorial_referent, heading: label_base[:other], allow_destroy: true, new_record: t('active_admin.has_many_new', model: label_base[:one]) do |ur|
        ur.input :category, as: :hidden, input_html: { value: 'territorial_referent' }
        collection_options = []

        all_territorial_zones = TerritorialZone.where(zone_type: 'region')
        existing_territorial_zones_by_code = {}

        all_territorial_zones.each do |tz|
          if !existing_territorial_zones_by_code[tz.code] || tz.zoneable_type == 'UserRight'
            existing_territorial_zones_by_code[tz.code] = tz
          end
        end

        # Add all available regions from RegionOrderingService
        RegionOrderingService.call.each do |region|
          if existing_territorial_zones_by_code[region.code]
            # Region has existing TerritorialZone - use TerritorialZone ID
            tz = existing_territorial_zones_by_code[region.code]
            collection_options << ["#{region.nom} (#{region.code})", tz.id]
          else
            collection_options << ["#{region.nom} (#{region.code})", region.code]
          end
        end

        ur.input :rightable_element_id,
                 collection: collection_options,
                 selected: ur.object&.rightable_element_id,
                 as: :select,
                 label: 'Région',
                 include_blank: 'Sélectionner une région'
        ur.input :rightable_element_type, as: :hidden, input_html: { value: 'TerritorialZone' }
      end

      # Droits admin
      label_base = t('activerecord.models.user_right.for_admin')
      f.has_many :user_rights_for_admin, heading: label_base[:other], allow_destroy: true, new_record: t('active_admin.has_many_new', model: label_base[:one]) do |ur|
        ur.input :category, as: :select, collection: UserRight::ADMIN_ONLY_CATEGORIES.map{ |cat| [I18n.t(cat, scope: "activerecord.attributes.user_right/categories"), cat] }, include_blank: false
      end
    end

    unless resource.persisted?
      f.inputs I18n.t('activerecord.models.expert.one') do
        f.input :create_expert, as: :boolean, label: I18n.t('active_admin.user.create_expert')
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

  member_action :normalize_values do
    resource.normalize_values!
    redirect_back_or_to collection_path, notice: t('active_admin.person.normalize_values_done')
  end

  member_action :invite_user do
    resource.invite!(current_user) unless resource.deleted?
    redirect_back_or_to collection_path, notice: t('active_admin.user.do_invite_done')
  end

  member_action :invite_to_demo do
    resource.invite_to_demo unless resource.deleted?
    redirect_back_or_to collection_path, notice: t('active_admin.user.invited_to_demo')
  end

  member_action :reset_password do
    resource.send_reset_password_instructions
    redirect_back_or_to collection_path, notice: t('active_admin.user.do_reset_password_done')
  end

  member_action :create_expert do
    resource.create_single_user_experts
    redirect_back_or_to collection_path, notice: t('active_admin.user.create_expert_done')
  end

  batch_action I18n.t('active_admin.user.do_invite') do |ids|
    batch_action_collection.find(ids).each do |user|
      user.invite!(current_user) unless user.deleted?
    end
    redirect_back_or_to collection_path, notice: I18n.t('active_admin.user.do_invite_done')
  end

  batch_action I18n.t('active_admin.user.invite_to_demo') do |ids|
    batch_action_collection.find(ids).each do |user|
      user.invite_to_demo unless user.deleted?
    end
    redirect_back_or_to collection_path, notice: I18n.t('active_admin.user.invited_to_demo')
  end

  batch_action :destroy, confirm: I18n.t('active_admin.users.delete_confirmation') do |ids|
    User.where(id: ids).find_each { |u| u.soft_delete }
    redirect_to collection_path, notice: I18n.t('active_admin.user.deleted')
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
