# frozen_string_literal: true

ActiveAdmin.register Expert do
  menu parent: :institutions, priority: 1
  permit_params %i[
    first_name
    last_name
    role
    institution_id
    email
    phone_number
    on_maubeuge
    on_valenciennes_cambrai
    on_calais
    on_lens
  ]

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :role
    column :institution
    column :on_maubeuge
    column :on_valenciennes_cambrai
    column :on_calais
    column :on_lens
    actions
  end

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :role
      f.input :institution
      f.input :email
      f.input :phone_number
      f.input :on_maubeuge
      f.input :on_valenciennes_cambrai
      f.input :on_calais
      f.input :on_lens
    end
    f.actions
  end
end
