# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        panel t('active_admin.dashboard_welcome.invite_users') do
          form action: send_invitation_emails_admin_users_path, method: :post do
            table do
              %w[email full_name institution role phone_number].each do |attribute|
                tr do
                  td { label(for: attribute) { t("activerecord.attributes.user.#{attribute}") } }
                  td { input id: attribute, type: 'text', name: attribute }
                end
              end
            end
            input name: 'authenticity_token', type: :hidden, value: form_authenticity_token.to_s
            input type: 'submit'
          end
        end
      end
    end
  end
end
