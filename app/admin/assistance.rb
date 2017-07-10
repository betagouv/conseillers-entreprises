# frozen_string_literal: true

ActiveAdmin.register Assistance do
  menu parent: :questions, priority: 2
  includes :question, :experts, :institution

  permit_params do
    permitted = [
      :id,
      :question_id,
      :institution_id,
      :title,
      :email_specific_sentence,
      :_destroy,
      assistances_experts_attributes: %i[id expert_id _create _update _destroy]
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
    column :email_specific_sentence, (proc { |assistance| assistance.email_specific_sentence.present? })
    actions
  end

  show do
    attributes_table do
      row :title
      row :question
      row :email_specific_sentence
    end
    panel I18n.t('active_admin.assistances.experts') do
      table_for assistance.experts do
        column :full_name, (proc { |expert| link_to(expert.full_name, admin_expert_path(expert)) })
        column :role
        column :institution
        column :on_maubeuge
        column :on_valenciennes_cambrai
        column :on_lens
        column :on_calais
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :question
      f.input :title
      f.input :institution
      f.input :email_specific_sentence
    end
    f.inputs I18n.t('active_admin.assistances.experts') do
      f.has_many :assistances_experts,
                 heading: false,
                 new_record: I18n.t('active_admin.assistances.add_expert'),
                 allow_destroy: true do |assistance_expert|
        assistance_expert.input :expert, label: I18n.t('active_admin.assistances.expert')
      end
    end
    f.actions
  end

  filter :title
  filter :question
  filter :institution
  filter :experts
  filter :created_at
  filter :updated_at
end
