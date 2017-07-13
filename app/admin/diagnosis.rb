# frozen_string_literal: true

ActiveAdmin.register Diagnosis do
  menu priority: 7
  actions :index, :show
  includes :visit
end
