# frozen_string_literal: true

ActiveAdmin.register CompanySatisfaction do
  menu parent: :companies, priority: 3

  ## Index
  #
  includes :need
  config.sort_order = 'created_at_desc'

  index do
    selectable_column
    column :contacted_by_expert
    column :useful_exchange
    column :comment
    column :need do |s|
      link_to s.need.to_s, diagnosis_path(s.need.diagnosis)
    end
    column :created_at
    actions dropdown: true
  end

  filter :contacted_by_expert
  filter :useful_exchange
end
