# frozen_string_literal: true

ActiveAdmin.register Assistance do
  menu parent: :questions, priority: 2

  permit_params do
    permitted = %i[question_id user_id company_id title email_specific_sentence]
    permitted << :other if params[:action] == 'create'
    permitted
  end

  index do
    selectable_column
    id_column
    column :question
    column :title
    column :user
    column :company
    column :email_specific_sentence, (proc { |assistance| assistance.email_specific_sentence.present? })
    actions
  end

  form do |f|
    f.inputs do
      f.input :question
      f.input :title
      f.input :user
      f.input :company
      f.input :geographic_scope
      f.input :county, as: :select, collection: Assistance::AUTHORIZED_COUNTIES
      f.input :email_specific_sentence
    end
    f.actions
  end
end
