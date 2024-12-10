# frozen_string_literal: true

ActiveAdmin.register Theme do
  menu priority: 6

  ## Index
  #
  config.sort_order = 'interview_sort_order_asc'
  includes :subjects, :institutions, :needs, :matches, :territories

  scope :all, group: :territories
  scope :with_territories, group: :territories

  index do
    selectable_column
    column(:label) do |t|
      div admin_link_to(t)
    end
    column :interview_sort_order
    column(:subjects) do |t|
      div admin_link_to(t, :subjects)
      div admin_link_to(t, :institutions)
    end
    column(:needs) do |t|
      div admin_link_to(t, :needs)
      div admin_link_to(t, :matches)
    end
    column t('active_admin.particularities') do |t|
      div t.territories.map(&:name).join(', ')
      div t('active_admin.specific_theme') if t.cooperation?
    end
    actions dropdown: true
  end

  filter :label

  ## CSV
  #
  csv do
    column :label
    column :interview_sort_order
    column_count :subjects
    column_count :institutions_subjects
  end

  ## Show
  #
  show do
    attributes_table do
      row :label
      row :interview_sort_order
      row(:subjects) { |t| admin_link_to(t, :subjects) }
      row(:institutions) { |t| admin_link_to(t, :institutions) }
      row(:cooperations) { |t| admin_link_to(t, :cooperations) }
    end
    attributes_table do
      row(:needs) { |t| admin_link_to(t, :needs) }
      row(:matches) { |t| admin_link_to(t, :matches) }
      row t('attributes.territories.other') do |t|
        t.territories.map { |r| admin_link_to r }.join(', ').html_safe
      end
    end
  end

  ## Form
  #
  permit_params :label, :interview_sort_order, territory_ids: []

  form do |f|
    f.inputs do
      f.input :label
      f.input :territories, as: :ajax_select, collection: Territory.order(:name), multiple: true, data: { url: :admin_territories_path, search_fields: [:name] }
      f.input :interview_sort_order
    end

    actions
  end
end
