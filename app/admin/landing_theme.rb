ActiveAdmin.register LandingTheme do
  menu parent: :themes, priority: 5

  include AdminArchivable

  scope :not_archived, default: true
  scope :is_archived

  controller do
    defaults :finder => :find_by_slug!
    def destroy
      begin
        resource.destroy
        redirect_to admin_landing_themes_path, notice: t('active_admin.landing_subjects.destroy_done')
      rescue ActiveRecord::DeleteRestrictionError => e
        redirect_to resource_path(resource), notice: I18n.t('activerecord.errors.models.landing_themes.restrict_dependent_destroy.solicitations')
      end
    end

    def update
      begin
        super
      rescue ActiveRecord::DeleteRestrictionError => e
        flash[:notice] = I18n.t('activerecord.errors.models.landing_subjects.restrict_dependent_destroy.solicitations')
        render action: :edit
      end
    end
  end

  ## Index
  #
  includes :landings, :landing_subjects

  index do
    selectable_column
    column :slug
    column(:title) { |t| admin_link_to t }
    column(:landings){ |t| admin_link_to(t, :landings) }
    column(:solicitations){ |t| admin_link_to(t, :solicitations) }
    column :is_archived
    actions dropdown: true
  end

  filter :title

  ## Show
  #
  show do
    attributes_table do
      row :title
      row :page_title
      row :slug
      row(:description) { |ls| ls.description&.html_safe }
      row :archived_at
      row :created_at
      row :updated_at
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
            row :archived_at
            row(:subject) { |ls| admin_link_to ls.subject }
            row(:description) { |ls| ls.description&.html_safe }
            row(:description_explanation) { |ls| ls.description_explanation&.html_safe }
            row(:description_prefill) { |ls| ls.description_prefill&.html_safe }
            row :form_title
            row(:form_description) { |ls| ls.form_description&.html_safe }
            row :fields_mode
            row :meta_title
            row :meta_description
          end
        end
      end
    end
  end

  ## Form
  #
  landing_subjects_attributes = [
    :id, :title, :slug, :subject_id, :description, :description_explanation, :description_prefill, :form_title, :form_description,
    :meta_title, :meta_description, :fields_mode, :archived_at,
    :position, :_destroy
  ]

  permit_params :title, :page_title, :slug, :description, :meta_title, :meta_description,
                landing_subjects_attributes: landing_subjects_attributes

  form title: :title do |f|
    f.inputs do
      f.input :title
      f.input :page_title
      f.input :slug
      f.input :description, input_html: { rows: 10 }
    end

    f.inputs I18n.t('active_admin.meta') do
      f.input :meta_title
      f.input :meta_description
    end

    f.inputs I18n.t('activerecord.attributes.landing_themes.landing_subjects') do
      f.has_many :landing_subjects, sortable: :position, sortable_start: 1, allow_destroy: true, new_record: true do |ls|
        ls.input :title

        ls.input :slug
        ls.input :subject, as: :ajax_select, data: { url: :admin_subjects_path, search_fields: [:label] }
        ls.input :description, as: :quill_editor
        ls.input :description_explanation, as: :quill_editor
        ls.input :description_prefill
        ls.input :form_title
        ls.input :fields_mode, as: :select, collection: LandingSubject.fields_modes, include_blank: false
        ls.input :form_description, as: :quill_editor
        ls.input :meta_title
        ls.input :meta_description
        ls.input :archived_at, as: :datepicker, datepicker_options: { min_date: "2017-01-01" }
      end
    end

    f.actions
  end
end
