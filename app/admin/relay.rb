# frozen_string_literal: true

ActiveAdmin.register Relay do
  menu parent: :territories, priority: 1
  permit_params :territory_id, :user_id
  includes :territory, :user

  ## Index
  #
  filter :territory_name, as: :string, label: I18n.t('activerecord.attributes.relay.territory')
  filter :user_full_name, as: :string, label: I18n.t('activerecord.attributes.relay.user')
  filter :created_at
  filter :updated_at

  ## Form
  #
  form do |f|
    inputs do
      f.input :territory, collection: Territory.ordered_by_name
      f.input :user, collection: User.ordered_by_names
    end
    actions
  end

  ## Show
  #
  show do
    default_main_content

    render partial: 'admin/matches', locals: { matches_relation: relay.matches }
  end
end
