ActiveAdmin.register SolicitationMailTemplate do
  menu parent: :solicitations, label: 'Templates emails auto'

  actions :index, :show, :edit, :update

  ## Index
  #
  index do
    column :email_type do |c|
      admin_link_to c
    end
    column :updated_at
    actions
  end

  ## Show
  #
  show do
    attributes_table do
      row :email_type
      row(:body_html) { |t| t.body_html.html_safe }
      row :created_at
      row :updated_at
    end
  end

  ## Form
  #
  permit_params :body_html

  form do |f|
    f.inputs do
      f.input :email_type, input_html: { disabled: true }
      f.input :body_html, as: :quill_editor
    end

    f.actions
  end
end
