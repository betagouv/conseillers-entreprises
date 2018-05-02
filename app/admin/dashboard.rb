# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    panel I18n.t('active_admin.dashboard_welcome.useful_links') do
      span link_to 'Trello', 'https://trello.com/b/TdTq4e5P/web', class: 'button'
      span link_to 'Mailtrap', 'https://mailtrap.io', class: 'button'
    end

    columns do
      column do
        panel t('active_admin.dashboard_welcome.invite_users') do
          form action: send_invitation_emails_admin_users_path, method: :post do
            table do
              %w[email first_name last_name institution role phone_number].each do |attribute|
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
      column class: 'attributes_table' do
        panel I18n.t('active_admin.dashboard_welcome.user_stats') do
          table do
            tr class: 'row' do
              th I18n.t('active_admin.dashboard_welcome.registered_users')
              td User.not_admin.count
            end
            range = (Time.now - 30.days)..Time.now
            tr class: 'row' do
              th I18n.t('active_admin.dashboard_welcome.searchers')
              td User.not_admin.active_searchers(range).count
            end
            tr class: 'row' do
              th I18n.t('active_admin.dashboard_welcome.diagnosers_2')
              td User.not_admin.active_diagnosers(range, 2).count
            end
            tr class: 'row' do
              th I18n.t('active_admin.dashboard_welcome.diagnosers_3')
              td User.not_admin.active_diagnosers(range, 3).count
            end
            tr class: 'row' do
              th I18n.t('active_admin.dashboard_welcome.diagnosers_4')
              td User.not_admin.active_diagnosers(range, 4).count
            end
            tr class: 'row' do
              th I18n.t('active_admin.dashboard_welcome.diagnosers_5')
              td User.not_admin.active_diagnosers(range, 5).count
            end
            tr class: 'row' do
              th I18n.t('active_admin.dashboard_welcome.answered_taken_care_of')
              td User.not_admin.active_answered(range, [1, 2]).count
            end
            tr class: 'row' do
              th I18n.t('active_admin.dashboard_welcome.answered_solved')
              td User.not_admin.active_answered(range, [2]).count
            end
          end
        end
      end
    end
  end
end
