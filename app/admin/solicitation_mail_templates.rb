ActiveAdmin.register SolicitationMailTemplate do
  menu parent: :solicitations, label: 'Templates emails auto'

  actions :index, :show, :edit, :update

  ## Index
  #
  index do
    column :title do |solicitation_mail_template|
      link_to solicitation_mail_template.title, admin_solicitation_mail_template_path(solicitation_mail_template)
    end
    column :email_type
    column :updated_at
    actions
  end

  ## Show
  #
  show do
    attributes_table do
      row :title
      row :email_type
      row :updated_at
    end

    panel "Aperçu de l'email" do
      solicitation = Solicitation.step_complete.joins(:landing_subject).find_random
      mail = SolicitationMailer.send(resource.email_type, solicitation)
      div mail.body.decoded.html_safe
    end
  end

  ## Form
  #
  permit_params :title, :body_html

  form do |f|
    f.inputs do
      f.input :title, as: :string,
              label: I18n.t('active_admin.solicitation_mail_templates.form.title.label'),
              hint: I18n.t('active_admin.solicitation_mail_templates.form.title.hint')
      unless f.object.new_record?
        f.input :email_type,
                label: I18n.t('active_admin.solicitation_mail_templates.form.email_type_edit.label'),
                input_html: { disabled: true }
      end
      f.input :body_html, as: :quill_editor
    end

    f.actions
  end
end
