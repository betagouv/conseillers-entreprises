# frozen_string_literal: true

ActiveAdmin.register DiagnosedNeed do
  menu parent: 'Diagnoses'
  actions :index, :show
  includes :diagnosis, :question
end
