# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    panel I18n.t('active_admin.dashboard_welcome.useful_links') do
      span link_to 'Trello', 'https://trello.com/b/TdTq4e5P/web', class: 'button'
      span link_to 'Mailtrap', 'https://mailtrap.io', class: 'button'
    end
  end
end
