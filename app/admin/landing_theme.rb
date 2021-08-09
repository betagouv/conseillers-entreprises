# frozen_string_literal: true

ActiveAdmin.register LandingTheme do
  menu parent: :themes, priority: 3

  controller do
    defaults :finder => :find_by_slug!
  end

  ## Index
  #
  includes :landings, :landing_subjects

  index do
    selectable_column
    column(:title) { |t| admin_link_to t }
    column(:landings){ |t| admin_link_to(t, :landings) }
    # column(:landing_subjects){ |t| admin_link_to(t, :landing_subjects) }
    actions dropdown: true
  end

  filter :title

  ## CSV
  #
  # csv do
  #   column :label
  #   column :interview_sort_order
  #   column_count :subjects
  #   column_count :institutions_subjects
  # end

  ## Show
  #
  show do
    attributes_table do
      row :title
      row :page_title
      row :slug
      row :description
      row :created_at
      row :updated_at
      row :logos
      row :main_logo
      row(:landings) do |t|
        div admin_link_to(t, :landings)
        div admin_link_to(t, :landings, list: true)
      end
    end

    attributes_table title: I18n.t('active_admin.meta') do
      row :meta_title
      row :meta_description
    end

    attributes_table title: I18n.t('activerecord.attributes.landing_themes.landing_subjects') do
      landing_theme.landing_subjects.order(:position).map do |s|
        panel s.title do
          attributes_table_for s do
            row :title
            row(:subject) { |ls| admin_link_to ls.subject }
            row :description
            row :description_explanation
            row :form_title
            row :form_description
            row :requires_location
            row :requires_requested_help_amount
            row :requires_siret
            row :meta_title
            row :meta_description
          end
        end
      end
    end
  end

  ## Form
  #
  landing_subjects_attributes = %i[
    id title slug subject_id description description_explanation form_title form_description meta_title
    meta_description requires_location requires_requested_help_amount requires_siret position _destroy
  ]

  permit_params :title, :page_title, :slug, :description, :logos, :main_logo, :meta_title, :meta_description,
                landing_subjects_attributes: landing_subjects_attributes

  form title: :title do |f|
    f.inputs do
      f.input :title
      f.input :page_title
      f.input :slug
      f.input :description, input_html: { rows: 10 }
      f.input :logos
      f.input :main_logo
    end

    f.inputs I18n.t('active_admin.meta') do
      f.input :meta_title
      f.input :meta_description
    end

    f.inputs I18n.t('active_admin.landing_subjects_order') do
      f.has_many :landing_subjects, sortable: :position, sortable_start: 1 do |ls|
        ls.input :position, label: ls.object.title, input_html: { style: 'width:10%' }
      end
    end

    f.inputs I18n.t('activerecord.attributes.landing_themes.landing_subjects') do
      f.has_many :landing_subjects, sortable: :position, sortable_start: 1, allow_destroy: true, new_record: true do |ls|
        ls.input :title
        ls.input :slug
        ls.input :subject, as: :ajax_select, data: { url: :admin_subjects_path, search_fields: [:label] }
        ls.input :description, input_html: { rows: 2 }
        ls.input :description_explanation, input_html: { rows: 8 }
        ls.input :form_title
        ls.input :form_description, input_html: { rows: 8 }
        ls.input :requires_location
        ls.input :requires_requested_help_amount
        ls.input :requires_siret
        ls.input :meta_title
        ls.input :meta_description
      end
    end

    f.actions
  end
end
