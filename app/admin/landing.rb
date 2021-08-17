ActiveAdmin.register Landing do
  menu parent: :themes, priority: 3

  includes :landing_subjects, :landing_themes

  controller do
    defaults :finder => :find_by_slug!
  end

  scope :all, default: true
  scope :iframes
  scope :locales

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
      div l.subtitle
      div l.logos&.truncate(50, separator: ', '), style: 'color: gray'
    end
    column :landing_themes do |l|
      div l.landing_themes.count
    end
    actions dropdown: true
  end

  ## Show
  #
  show title: :slug do
    panel I18n.t("activerecord.models.landing.one") do
      attributes_table_for landing do
        row :title
        row :subtitle
        row :slug do |l|
          div link_to l.slug, l if l.slug.present?
        end
        row :layout
        row :iframe
        row :logos
        row :custom_css
        row :message_under_landing_topics do |l|
          l.message_under_landing_topics&.html_safe
        end
        row :created_at
        row :updated_at
      end
    end

    attributes_table title: I18n.t("landings.landing_subjects.new_solicitation_form.form") do
      row :institution
      row :partner_url
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

  permit_params :slug,
                :institution_id, :iframe,
                :home_title, :home_description, :home_sort_order,
                :meta_title, :meta_description,
                :emphasis,
                :title, :subtitle, :logos,
                :custom_css,
                :message_under_landing_topics, :partner_url,
                landing_joint_themes_attributes: landing_joint_themes_attributes

  form title: :title do |f|
    f.inputs do
      f.input :title
      f.input :slug
      f.input :iframe
    end

    f.inputs I18n.t("landings.landing_subjects.new_solicitation_form.form") do
      f.input :institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
      f.input :partner_url
    end

    f.inputs I18n.t("activerecord.attributes.landing.featured_on_home") do
      f.input :home_title
      f.input :home_description, input_html: { rows: 2 }
      f.input :emphasis, as: :boolean
    end

    panel I18n.t("activerecord.models.landing.one") do
      f.inputs do
        f.input :meta_title
        f.input :meta_description
      end

      f.inputs do
        f.input :title
        f.input :subtitle
        f.input :logos
        f.input :custom_css, as: :text, input_html: { style: 'font-family:monospace', rows: 10 }
        f.input :message_under_landing_topics, as: :text, input_html: { rows: 3 }
      end
    end

    f.inputs do
      f.has_many :landing_joint_themes, sortable: :position, sortable_start: 1, allow_destroy: true, new_record: true do |ljt|
        ljt.input :landing_theme, as: :ajax_select, data: { url: :admin_landing_themes_path, search_fields: [:title] }
      end
    end

    f.actions
  end
end
