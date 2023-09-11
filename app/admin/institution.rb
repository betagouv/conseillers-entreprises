# frozen_string_literal: true

ActiveAdmin.register Institution do
  menu parent: :experts, priority: 2

  controller do
    include SoftDeletable::ActiveAdminResourceController
  end

  scope :active, default: true
  scope :deleted

  scope :expert_provider, group: :categories
  scope :acquisition, group: :categories
  scope :opco, group: :categories

  ## Index
  #
  config.sort_order = 'slug_asc'

  controller do
    defaults :finder => :find_by_slug!

    def scoped_collection
      super.preload :advisors, :subjects, :institutions_subjects, :logo, :antennes, :experts
    end
  end

  index do
    selectable_column
    column :image, class: 'logo' do |l|
      display_logo(name: l.logo&.filename, path: "institutions/") if l.logo.present?
    end
    column(:name) do |i|
      div admin_link_to(i)
      div admin_link_to(i, :antennes)
      div admin_link_to(i, :subjects)
    end
    column(:community) do |i|
      div(admin_link_to(i, :advisors))
      div(admin_link_to(i, :experts))
    end
    column(:activity) do |i|
      div admin_link_to(i, :sent_matches, blank_if_empty: true)
      div admin_link_to(i, :received_matches, blank_if_empty: true)
    end
  end

  filter :name

  ## CSV
  #
  csv do
    column :name
    column_count :antennes
    column_count :advisors
    column_count :experts
    column_count :sent_matches
    column_count :received_matches
  end

  ## Show
  #
  show do
    attributes_table do
      row(:deleted_at) if resource.deleted?
      row :name
      row :slug
      row :categories do |i|
        div i.categories.map{ |c| I18n.t('active_admin.scopes.' + c.label) }.join(', ')
      end
      row :siren
      row(:antennes) do |i|
        div admin_link_to(i, :antennes)
      end
      row(:community) do |i|
        div admin_link_to(i, :advisors)
        div admin_link_to(i, :experts)
      end
      row(:activity) do |i|
        div admin_link_to(i, :sent_matches)
        div admin_link_to(i, :received_matches)
      end
      row(:code_region) do |i|
        I18n.t(i.code_region, scope: 'regions_codes_to_libelles', default: "")
      end
      row(:logo) do |i|
        display_logo(name: i.logo&.filename, path: "institutions/") if i.logo.present?
      end
      row :display_logo
      row :show_on_list
    end

    attributes_table title: I18n.t('activerecord.models.institution_subject.other') do
      table_for institution.institutions_subjects.ordered_for_interview do
        column(:theme)
        column(:subject)
        column(:description)
        column(:archived_at) { |is| is.subject.archived_at }
      end
    end

    attributes_table title: I18n.t('activerecord.models.institution_filter.other') do
      table_for institution.institution_filters do
        column(:label) { |filter| I18n.t(:label, scope: [:activerecord, :attributes, :additional_subject_questions, filter.key]) }
        column(:key)
        column(:filter_value)
      end
    end
  end

  ## Form
  #
  permit_params :name, :display_logo, :slug, :show_on_list, :code_region, :siren,
                antenne_ids: [], category_ids: [],
                institutions_subjects_attributes: %i[id description subject_id _create _update _destroy]

  form do |f|
    f.inputs do
      f.input :name
      f.input :slug
      f.input :display_logo
      f.input :show_on_list
      f.input :code_region, as: :select, collection: Territory.regions.map{ |r| [r.name, r.code_region] }
      f.input :categories, as: :check_boxes, collection: Category.all.map{ |c| [I18n.t('active_admin.scopes.' + c.label), c.id] }
      f.input :siren, input_html: { rows: 1 }
    end
    f.inputs do
      f.input :antennes,
              as: :ajax_select,
              collection: resource.antennes,
              data: {
                url: :admin_antennes_path,
                search_fields: [:name]
              }
    end
    f.has_many :institutions_subjects, heading: t('activerecord.attributes.institution.subjects'), allow_destroy: true do |sub_f|
      themes = Theme.all.ordered_for_interview
      collection = option_groups_from_collection_for_select(themes, :subjects_ordered_for_interview, :label, :id, :label, sub_f.object&.subject&.id)
      sub_f.input :subject, collection: collection
      sub_f.input :description
    end

    f.actions
  end

  ## Actions
  #
  # Delete default destroy action to create a new one with more explicit alert message
  config.action_items.delete_at(2)

  action_item :destroy, only: :show do
    link_to t('active_admin.institution.delete'), { action: :destroy }, method: :delete, data: { confirm: t('active_admin.institution.delete_confirmation') }
  end

  batch_action :destroy, confirm: I18n.t('active_admin.institution.delete_confirmation') do |ids|
    Institution.where(id: ids).each { |u| u.soft_delete }
    redirect_to collection_path, notice: I18n.t('active_admin.institutions.deleted')
  end
end
