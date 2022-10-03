ActiveAdmin.register Landing do
  menu parent: :themes, priority: 3

  include AdminArchivable

  includes :landing_subjects, :landing_themes

  controller do
    defaults :finder => :find_by_slug!
  end

  scope :not_archived, default: true
  scope :intern
  scope :iframe
  scope :api
  scope :is_archived

  ## Index
  #
  index do
    selectable_column
    column :slug do |l|
      admin_link_to l
    end
    column :title do |l|
      div admin_link_to l.institution if l.institution.present?
      div link_to l.title, l if l.slug.present?
    end
    column :iframe_category do |l|
      div l.iframe? ? (human_attribute_status_tag l, :iframe_category) : '-'
    end
    column :landing_themes do |l|
      div l.landing_themes.count
    end
    column :solicitations do |l|
      div l.solicitations.count
    end
    column :is_archived
    actions dropdown: true do |l|
      item t('active_admin.landings.update_iframe_360_button'), update_iframe_360_admin_landing_path(l), method: :put
    end
  end

  filter :title
  filter :slug
  filter :landing_themes, as: :ajax_select, data: { url: :admin_landing_themes_path, search_fields: [:title] }
  filter :institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :iframe_category, as: :select, collection: -> { Landing.human_attribute_values(:iframe_category, raw_values: true).invert.to_a }

  ## Show
  #
  show title: :slug do
    panel I18n.t("activerecord.models.landing.one") do
      attributes_table_for landing do
        row :title
        row :slug do |l|
          div link_to l.slug, l if l.slug.present?
        end
        row :created_at
        row :updated_at
        row :archived_at
        row(:layout) { |landing| human_attribute_status_tag landing, :layout }
        row(:integration) { |landing| human_attribute_status_tag landing, :integration }
      end
    end

    attributes_table title: I18n.t("activerecord.attributes.landing.featured_on_home") do
      row :emphasis
      row :home_description
      row :main_logo
    end

    attributes_table title: I18n.t("landings.landings.admin.iframe_and_api_fields") do
      row :institution
      row :partner_url
    end

    attributes_table title: I18n.t("landings.landings.admin.iframe_fields") do
      row(:iframe_category) { |landing| human_attribute_status_tag landing, :iframe_category }
      row :custom_css
      row :display_pde_partnership_mention
    end

    attributes_table title: I18n.t("active_admin.meta") do
      row :meta_title
      row :meta_description
    end

    attributes_table title: I18n.t('activerecord.attributes.landing.landing_themes') do
      table_for landing.landing_themes do
        column(:title) { |t| admin_link_to t }
        column(:landing_subjects) { |t| div t.landing_subjects.map { |l| div l.title } }
      end
    end
  end

  landing_joint_themes_attributes = %i[id landing_theme_id position _destroy]

  permit_params :slug, :title,
                :layout,
                :emphasis, :home_description, :main_logo,
                :meta_title, :meta_description,
                :integration, :institution_id, :partner_url,
                :iframe_category, :custom_css, :display_pde_partnership_mention,
                landing_joint_themes_attributes: landing_joint_themes_attributes

  form title: :title do |f|
    f.inputs do
      f.input :title
      f.input :slug
      f.input :layout, as: :select, collection: Landing.human_attribute_values(:layout).invert
      f.input :integration, as: :select, collection: Landing.human_attribute_values(:integration).invert
    end

    f.inputs I18n.t("activerecord.attributes.landing.featured_on_home") do
      f.input :emphasis, as: :boolean
      f.input :home_description, input_html: { rows: 2 }
      f.input :main_logo
    end

    f.inputs I18n.t("landings.landings.admin.iframe_and_api_fields") do
      f.input :institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
      f.input :partner_url
    end

    f.inputs I18n.t("landings.landings.admin.iframe_fields") do
      f.input :iframe_category, as: :select, collection: Landing.human_attribute_values(:iframe_category).invert
      f.input :custom_css, as: :text, input_html: { style: 'font-family:monospace', rows: 10 }
      f.input :display_pde_partnership_mention
    end

    panel I18n.t("active_admin.meta") do
      f.inputs do
        f.input :meta_title
        f.input :meta_description
      end
    end

    f.inputs do
      f.has_many :landing_joint_themes, sortable: :position, sortable_start: 1, allow_destroy: true, new_record: true do |ljt|
        ljt.input :landing_theme, as: :ajax_select, data: { url: :admin_landing_themes_path, search_fields: [:title] }
      end
    end

    f.actions
  end

  ## Actions
  #
  action_item :update_iframe_360, only: :show, if: ->{ resource.iframe? && resource.integral_iframe? } do
    link_to t('active_admin.landings.update_iframe_360_button'), update_iframe_360_admin_landing_path(resource), method: :put
  end

  member_action :update_iframe_360, method: :put do
    resource.update_iframe_360
    redirect_to resource_path(resource), alert: I18n.t('active_admin.landings.update_iframe_360_done')
  end

  batch_action I18n.t('active_admin.landings.update_iframe_360_button') do |ids|
    batch_action_collection.find(ids).each do |landing|
      landing.update_iframe_360
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('active_admin.landings.update_iframe_360_done')
  end
end
