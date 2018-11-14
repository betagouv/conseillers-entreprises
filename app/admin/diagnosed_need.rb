# frozen_string_literal: true

ActiveAdmin.register DiagnosedNeed do
  menu parent: :diagnoses, priority: 1
  actions :index, :show
  includes :diagnosis, :question, :matches

  scope :all, default: true
  scopes = [:unsent, :with_no_one_in_charge, :abandoned, :being_taken_care_of, :done]
  scopes.each do |s|
    scope I18n.t("active_admin.diagnosed_needs.scopes.#{s}"), s
  end

  ## index
  #
  filter :diagnosis, collection: -> { Diagnosis.order(created_at: :desc).pluck(:id) }
  filter :question, collection: -> { Question.order(:label) }
  filter :question_label
  filter :content
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    id_column
    column :diagnosis
    column :question_label
    column :question
    column :created_at
    column :updated_at
    column :content
    column :status_synthesis do |n|
      t("activerecord.attributes.match.statuses_short.#{n.status_synthesis}")
    end
    column t('activerecord.models.match.other'), :matches_count

    actions
  end

  ## Show
  #
  show do
    default_main_content

    render partial: 'admin/matches', locals: { matches: diagnosed_need.matches }
  end
end
