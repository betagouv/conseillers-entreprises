# frozen_string_literal: true

ActiveAdmin.register Facility do
  menu parent: :companies, priority: 1
  includes :company

  preserve_default_filters!
  remove_filter :company
  filter :company_name, as: :string, label: I18n.t('activerecord.attributes.facility.company')
end
