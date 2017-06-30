# frozen_string_literal: true

ActiveAdmin.register Expert do
  menu parent: :institutions, priority: 1
  permit_params [
    :first_name,
    :last_name,
    :role,
    :institution_id,
    :email,
    :phone_number,
    :on_maubeuge,
    :on_valenciennes_cambrai,
    :on_calais,
    :on_lens,
    assistances_experts_attributes: %i[id _create _update _destroy assistance_id]
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

  show do
    attributes_table do
      row :first_name
      row :last_name
      row :role
      row :institution
      row :email
      row :on_maubeuge
      row :on_valenciennes_cambrai
      row :on_calais
      row :on_lens
    end
    panel I18n.t('active_admin.experts.assistances') do
      table_for expert.assistances do
        column :title, (proc { |assistance| link_to(assistance.title, admin_assistance_path(expert)) })
        column :question
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :role
      f.input :institution
      f.input :email
      f.input :phone_number
    end
    f.inputs I18n.t('active_admin.experts.perimeter') do
      f.input :on_maubeuge
      f.input :on_valenciennes_cambrai
      f.input :on_calais
      f.input :on_lens
    end
    f.inputs I18n.t('active_admin.experts.assistances') do
      f.has_many :assistances_experts,
                 heading: false,
                 new_record: I18n.t('active_admin.experts.add_assistance'),
                 allow_destroy: true do |assistance_expert|
        assistance_expert.input :assistance, label: I18n.t('active_admin.experts.assistance')
      end
    end
    f.actions
  end
end
