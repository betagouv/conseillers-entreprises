# frozen_string_literal: true

ActiveAdmin.register DiagnosedNeed do
  menu parent: :diagnoses, priority: 1
  actions :index, :show
  includes :diagnosis, :question
end
