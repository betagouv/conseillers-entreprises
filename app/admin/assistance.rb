# frozen_string_literal: true

ActiveAdmin.register Assistance do
  menu parent: :questions, priority: 3
  includes :question, :experts

  permit_params do
    permitted = [
      :id,
      :question_id,
      :title,
      :description,
      :_destroy,
      assistances_experts_attributes: %i[id expert_id _create _update _destroy]
    ]

    if params[:action] == 'create'
      permitted << :other
    end

    permitted
  end

  index do
    selectable_column
    id_column
    column :question
    column :title
    column :experts, (proc { |assistance| assistance.experts.size })
    actions
  end

  show do
    attributes_table do
      row :question
      row :title
      row :description
    end

    panel I18n.t('activerecord.attributes.assistance.experts') do
      table_for assistance.experts do
        column :full_name, (proc { |expert| link_to(expert.full_name, admin_expert_path(expert)) })
        column :role
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :question
      f.input :title
      f.input :description
    end
    f.actions
  end

  filter :title
  filter :question
  filter :experts
  filter :created_at
  filter :updated_at
end
