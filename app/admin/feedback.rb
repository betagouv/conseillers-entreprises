ActiveAdmin.register Feedback do
  include CsvExportable
  menu parent: :needs, priority: 3

  scope :all, group: :all

  scope :for_need, group: :type, default: true
  scope :for_solicitation, group: :type
  scope :for_expert, group: :type

  ## Index
  #
  includes [feedbackable: [:facility, :company, :subject]], # feedbackable is either a Need or a Solicitation; ActiveRecord’s magic does the right thing here.
           user: [:institution, :antenne]

  index do
    selectable_column
    id_column
    column :created_at
    column :feedbackable
    column(:category) { |feedback| human_attribute_status_tag feedback, :category }
    column :user
    column :description

    actions dropdown: true
  end

  filter :subject, as: :ajax_select, collection: -> { Subject.not_archived.pluck(:label, :id) }, data: { url: :admin_subjects_path, search_fields: [:label] }
  filter :theme, as: :select, collection: -> { Theme.order(:label).pluck(:label, :id) }
  filter :landing, as: :ajax_select, data: { url: :admin_landings_path, search_fields: [:title] }
  filter :mtm_campaign, as: :string
  filter :mtm_kwd, as: :string
  filter :description
  filter :category, as: :select, collection: -> { Feedback.human_attribute_values(:category, raw_values: true).invert.to_a }
  filter :need_created_at, as: :date_range, label: I18n.t('activeadmin.feedback.need_created_at')
  filter :created_at, as: :date_range, label: I18n.t('activeadmin.feedback.created_at')
  filter :user, as: :ajax_select, data: { url: :admin_users_path, search_fields: [:full_name] }
  filter :user_antenne, as: :ajax_select, data: { url: :admin_antennes_path, search_fields: [:name] }
  filter :user_institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }

  ## CSV
  #
  csv do
    column :id
    column :created_at
    column :feedbackable
    column(:category) { |feedback| feedback.human_attribute_value(:category) }
    column :user
    column :description
    column(:siret) { |f| f.need&.facility&.siret }
    column(:institution) { |f| f.user.institution }
    column(:antenne) { |f| f.user.antenne }
  end

  ## Show
  #
  show do
    attributes_table do
      row :created_at
      row :feedbackable
      row(:category) { |feedback| human_attribute_status_tag feedback, :category }
      row :user
      row :description
    end
  end

  ## Form
  #
  permit_params :description

  form do |f|
    f.input :description

    actions
  end
end
