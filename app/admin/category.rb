# frozen_string_literal: true

ActiveAdmin.register Category do
  menu parent: :questions, priority: 1
  permit_params :label, :interview_sort_order
end
