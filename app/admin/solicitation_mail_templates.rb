ActiveAdmin.register SolicitationMailTemplate do
  menu parent: :solicitations, label: 'Templates emails auto'

  actions :index, :show, :edit, :update

  ## Index
  #
  index do
    column :email_type do |solicitation_mail_template|
      link_to solicitation_mail_template, admin_solicitation_mail_template_path(solicitation_mail_template)
    end
    column :updated_at
    actions
  end

  ## Show
  #
  show do
    attributes_table do
      row :email_type do |solicitation_mail_template|
        solicitation_mail_template.to_s
      end
      row :updated_at
    end

    panel 'Aperçu du corps' do
      div resource.body_html.html_safe
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
