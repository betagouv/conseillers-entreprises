ActiveAdmin.register Audited::Audit do
  actions :index

  ## Index
  #
  index do
    selectable_column
    column(:user) do |i|
      div admin_link_to(i.user) if i.user.present?
      expert = i.revision.is_a?(Expert) ? i.revision : i.revision.expert
      if expert&.persisted?
        div admin_link_to(expert)
        div admin_link_to(expert.antenne)
      end
    end
    column(:action) do |i|
      status_tag t(i.action, scope: 'activerecord.attributes.audited.action'), class: i.action
    end
    column(:auditable_type) do |i|
      div i.auditable_type.constantize.model_name.human
    end
    column(:type_concerne) do |i|
      i.revision.admin_description
    end
    column(:modifications) do |i|
      i.admin_changes
    end
    column(:created_at)
  end
  actions = ['update', 'destroy', 'create'].map { |s| Audited::Audit.human_attribute_name("action.#{s}") }
  filter :created_at
  filter :action, as: :select, collection: -> { actions }
  filter :auditable_type
end
