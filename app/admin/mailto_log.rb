# frozen_string_literal: true

ActiveAdmin.register MailtoLog do
  menu parent: :questions, priority: 3
  actions :index, :show
  includes :question, :visit, :assistance, visit: [:facility, facility: :company]

  filter :question_id, label: 'ID Besoin'
  filter :visit_id, label: 'ID Visite'
  filter :assistance_id, label: 'ID Aide'
  filter :created_at
  filter :updated_at
end
