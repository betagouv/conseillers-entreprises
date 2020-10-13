# frozen_string_literal: true

ActiveAdmin.register Institution do
  menu parent: :experts, priority: 2

  controller do
    include SoftDeletable::ActiveAdminResourceController
  end

  ## Index
  #
  includes :antennes, :subjects, :advisors, :experts, :sent_matches, :received_matches
  config.sort_order = 'slug_asc'

  controller do
    defaults :finder => :find_by_slug!
  end

  index do
    selectable_column
    column(:name) do |i|
      div admin_link_to(i)
      div admin_link_to(i, :antennes)
      div admin_link_to(i, :subjects)
    end
    column(:community) do |i|
      div admin_link_to(i, :advisors)
      div admin_link_to(i, :experts)
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
      row :logo_sort_order
      row :region_name
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
  end

  ## Form
  #
  permit_params :name, :logo_sort_order, :slug, :show_on_list, :region_name,
                antenne_ids: [],
                institutions_subjects_attributes: %i[id description subject_id _create _update _destroy]

  form do |f|
    f.inputs do
      f.input :name
      f.input :slug
      f.input :logo_sort_order, input_html: { style: 'width:300px', placeholder: I18n.t('active_admin.landings.home_sort_order_placeholder') }
      f.input :region_name, input_html: { placeholder: I18n.t('active_admin.landings.region_name_placeholder') }
      f.input :show_on_list
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
end
