# frozen_string_literal: true

ActiveAdmin.register DiagnosedNeed do
  menu parent: :diagnoses, priority: 1

  ## index
  #
  includes :diagnosis, :question, :advisor, :matches, :company

  scope :all, default: true
  scope :unsent
  scope :with_no_one_in_charge
  scope :abandoned
  scope :being_taken_care_of
  scope :done

  index do
    selectable_column
    column :question do |d|
      div admin_link_to(d)
      div admin_attr(d, :content)
    end
    column :advisor
    column :created_at
    column :status do |d|
      css_class = { quo: '', taking_care: 'warning', done: 'ok', not_for_me: 'error' }[d.status_synthesis.to_sym]
      status_tag d.status_short_description, class: css_class
    end
    column(:matches) do |d|
      div admin_link_to(d, :matches)
    end

    actions dropdown: true
  end

  filter :company, as: :ajax_select, data: { url: :admin_companies_path, search_fields: [:name] }
  filter :question, collection: -> { Question.order(:label) }
  filter :content
  filter :created_at

  ## CSV
  #
  csv do
    column :question
    column :content
    column :advisor
    column :created_at
    column :status_short_description
    column_count :matches
  end

  ## Show
  #
  show do
    attributes_table do
      row :diagnosis
      row :question
      row :advisor
      row :created_at
      row :content
      row :status_description do |d|
        css_class = { quo: '', taking_care: 'warning', done: 'ok', not_for_me: 'error' }[d.status_synthesis.to_sym]
        status_tag d.status_description, class: css_class
      end
      row(:matches) do |d|
        div admin_link_to(d, :matches)
      end
    end

    render partial: 'admin/matches', locals: { matches: diagnosed_need.matches }
  end

  ## Form
  #
  permit_params :diagnosis_id, :question_id, :content

  form do |f|
    f.inputs do
      f.input :question, as: :ajax_select, data: { url: :admin_questions_path, search_fields: [:label] }
      f.input :content
    end

    actions
  end
end
