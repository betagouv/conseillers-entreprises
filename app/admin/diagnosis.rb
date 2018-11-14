# frozen_string_literal: true

ActiveAdmin.register Diagnosis do
  menu priority: 7
  includes visit: [:advisor, facility: :company]

  filter :visit, collection: -> { Visit.includes(facility: :company).joins(facility: :company).order('companies.name') }
  filter :content
  filter :created_at
  filter :updated_at
  filter :archived_at
  filter :step

  show do
    attributes_table do
      row :visit
      row :created_at
      row :updated_at
      row :archived_at
      row(:advisor) { |d| d.visit.advisor }
      row :step
      row :description
    end

    panel I18n.t('activerecord.models.diagnosed_need.other') do
      table_for diagnosis.diagnosed_needs do
        column(:id) { |n| link_to(n.id, admin_diagnosed_need_path(n)) }
        column(:category) { |n| n.question&.category&.label }
        column :question_label
        column(:content) { |n| link_to(n.content, admin_diagnosed_need_path(n)) }
      end
    end

    render partial: 'admin/matches', locals: { matches: diagnosis.matches }
  end
end
