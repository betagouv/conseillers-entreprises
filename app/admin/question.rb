# frozen_string_literal: true

ActiveAdmin.register Question do
  menu priority: 5
  permit_params :category_id, :label, :interview_sort_order
  includes :category

  filter :label
  filter :assistances, collection: -> { Assistance.order(:title).map { |a| ["#{a.title} (#{a.id})", a.id] } }
  filter :diagnosed_needs, collection: -> { DiagnosedNeed.order(created_at: :desc).pluck(:id) }
  filter :category, collection: -> { Category.order(:label) }
  filter :created_at
  filter :updated_at
end
