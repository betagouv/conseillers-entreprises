# frozen_string_literal: true

ActiveAdmin.register Assistance do
  menu parent: :questions, priority: 2

  permit_params do
    permitted = [
      :id,
      :_destroy,
      :question_id,
      :institution_id,
      :title,
      :email_specific_sentence,
      :for_maubeuge,
      :for_valenciennes_cambrai,
      :for_calais,
      :for_lens,
      assistances_experts_attributes: %i[id _create _update _destroy expert_id]
    ]
    permitted << :other if params[:action] == 'create'
    permitted
  end

  index do
    selectable_column
    id_column
    column :question
    column :title
    column :experts, (proc { |assistance| assistance.experts.size })
    column :institution
    column :for_maubeuge
    column :for_valenciennes_cambrai
    column :for_calais
    column :for_lens
    column :email_specific_sentence, (proc { |assistance| assistance.email_specific_sentence.present? })
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :question
      f.input :title
      f.input :institution
      f.input :for_maubeuge
      f.input :for_valenciennes_cambrai
      f.input :for_calais
      f.input :for_lens
      f.input :email_specific_sentence
      f.has_many :assistances_experts, allow_destroy: true do |assistance_expert|
        assistance_expert.input :expert
      end
    end
    f.actions
  end
end

ActiveAdmin.register Category do
  menu parent: :questions, priority: 1
  permit_params :label
end
