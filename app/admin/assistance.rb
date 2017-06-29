# frozen_string_literal: true

ActiveAdmin.register Assistance do
  menu parent: :questions, priority: 2

  permit_params do
    permitted = %i[
      question_id
      expert_id
      institution_id
      title
      email_specific_sentence
      for_maubeuge
      for_valenciennes_cambrai
      for_calais
      for_lens
    ]
    permitted << :other if params[:action] == 'create'
    permitted
  end

  index do
    selectable_column
    id_column
    column :question
    column :title
    column :expert
    column :institution
    column :for_maubeuge
    column :for_valenciennes_cambrai
    column :for_calais
    column :for_lens
    column :email_specific_sentence, (proc { |assistance| assistance.email_specific_sentence.present? })
    actions
  end

  form do |f|
    f.inputs do
      f.input :question
      f.input :title
      f.input :expert
      f.input :institution
      f.input :for_maubeuge
      f.input :for_valenciennes_cambrai
      f.input :for_calais
      f.input :for_lens
      f.input :email_specific_sentence
    end
    f.actions
  end
end
