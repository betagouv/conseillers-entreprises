ActiveAdmin.register Need do
  menu priority: 8

  controller do
    include DynamicallyFiltrable

    helper :active_admin_utilities
  end

  ## index
  #
  before_action only: :index do
    init_subjects_filter
  end

  includes :diagnosis, :subject, :advisor, :matches, :feedbacks, :company

  scope :diagnosis_completed, group: :status, default: true
  scope :all, group: :status

  index do
    selectable_column
    column :subject do |d|
      div admin_link_to(d)
      div admin_attr(d, :content)
    end
    column :advisor
    column :created_at
    column :updated_at
    column :status do |need|
      human_attribute_status_tag need, :status
      status_tag I18n.t('attributes.is_abandoned') if need.is_abandoned?
    end
    column(:matches) do |d|
      div admin_link_to(d, :matches)
      div admin_link_to(d, :feedbacks)
    end
  end

  filter :status, as: :select, collection: -> { Need.human_attribute_values(:status, raw_values: true).invert.to_a }
  filter :created_at
  filter :company, as: :ajax_select, data: { url: :admin_companies_path, search_fields: [:name] }
  filter :facility_naf_code_a10, as: :select, collection: -> { naf_a10_collection }
  filter :company_simple_effectif, as: :select, collection: -> { simple_effectif_collection }
  filter :theme, as: :select, collection: -> { Theme.order(:label).pluck(:label, :id) }
  filter :subject, as: :ajax_select, collection: -> { @subjects.pluck(:label, :id) }, data: { url: :admin_subjects_path, search_fields: [:label] }
  filter :content
  filter :experts, as: :ajax_select, data: { url: :admin_experts_path, search_fields: [:full_name] }
  filter :expert_antennes, as: :ajax_select, data: { url: :admin_antennes_path, search_fields: [:name] }
  filter :expert_institutions, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :facility_regions, as: :select, collection: -> { Territory.regions.order(:name).pluck(:name, :id) }

  ## CSV
  #
  csv do
    column :subject
    column :content
    column :advisor
    column :created_at
    column :updated_at
    column(:status) { |need| need.human_attribute_value(:status, context: :short) }
    column_count :matches
    column(:matched_antennes) { |n| n.experts.map{ |e| e.antenne.name }.join(', ') }
  end

  ## Show
  #
  show do
    attributes_table do
      row :diagnosis
      row :subject
      row :advisor
      row :created_at
      row :updated_at
      row(:abandoned) { |n| n.is_abandoned? }
      row :content
      row(:status) { |need| human_attribute_status_tag need, :status }
      row(:matches) do |d|
        div admin_link_to(d, :matches)
        div admin_link_to(d, :matches, list: true)
      end
    end
  end

  ## Form
  #
  permit_params :diagnosis_id, :subject_id, :content

  form do |f|
    f.inputs do
      f.input :subject, as: :ajax_select, data: { url: :admin_subjects_path, search_fields: [:label] }
      f.input :content
    end

    actions
  end
end
