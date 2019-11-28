# frozen_string_literal: true

ActiveAdmin.register Institution do
  menu parent: :experts, priority: 2

  ## Index
  #
  includes :antennes, :advisors, :experts, :sent_matches, :received_matches
  config.sort_order = 'name_asc'

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
      div admin_link_to(i, :sent_matches)
      div admin_link_to(i, :received_matches)
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
      row :name
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
      row :show_icon
      row(:subjects) do |i|
        safe_join(i.institutions_subjects.map do |is|
          link_to "#{is.subject} (#{is.description})", admin_subject_path(is.subject)
        end, '<br /> '.html_safe)
      end
    end
  end

  ## Form
  #
  permit_params :name, :show_icon,
                antenne_ids: [],
                institutions_subjects_attributes: %i[id description subject_id _create _update _destroy]

  form do |f|
    f.inputs do
      f.input :name
      f.input :show_icon
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
      themes = Theme.all
      collection = option_groups_from_collection_for_select(themes, :subjects, :label, :id, :label, sub_f.object&.subject&.id)
      sub_f.input :subject, collection: collection
      sub_f.input :description
    end

    f.actions
  end
end
