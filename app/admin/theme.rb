ActiveAdmin.register Theme do
  menu priority: 6

  ## Index
  #
  config.sort_order = 'interview_sort_order_asc'
  includes :territories, :cooperations

  scope :all, group: :territories
  scope :with_territories, group: :territories

  index do
    selectable_column
    column(:label) do |t|
      div admin_link_to(t)
    end
    column :interview_sort_order
    column(:subjects) do |t|
      div admin_link_to(t, :subjects)
      div admin_link_to(t, :institutions)
    end
    column(:needs) do |t|
      div admin_link_to(t, :needs)
      div admin_link_to(t, :matches)
    end
    column t('active_admin.particularities') do |t|
      div t.cooperations.map { |r| admin_link_to r }.join(', ').html_safe
      territorial_zone_column_content(t)
    end

    actions dropdown: true
  end

  filter :label

  ## CSV
  #
  csv do
    column :label
    column :interview_sort_order
    column_count :subjects
    column_count :institutions_subjects
  end

  ## Show
  #
  show do
    attributes_table do
      row :label
      row :interview_sort_order
      row(:subjects) { |t| admin_link_to(t, :subjects) }
      row(:institutions) { |t| admin_link_to(t, :institutions) }
      row(:cooperations) do |t|
        t.cooperations.map { |r| admin_link_to r }.join(', ').html_safe
      end
    end
    attributes_table do
      row(:needs) { |t| admin_link_to(t, :needs) }
      row(:matches) { |t| admin_link_to(t, :matches) }
    end
    panel I18n.t('activerecord.models.territorial_zone.other') do
      if theme.territorial_zones.any?
        displays_territories(theme.territorial_zones)
      end
    end
  end

  ## Form
  #
  permit_params :label, :interview_sort_order, territorial_zones_attributes: [:id, :zone_type, :code, :_destroy]

  form do |f|
    f.inputs do
      f.input :label
      f.input :interview_sort_order
    end

    f.inputs do
      f.has_many :territorial_zones, allow_destroy: true, new_record: true do |tz|

        tz.input :zone_type,
                 as: :select,
                 collection: TerritorialZone.zone_types.map { |k, v| [I18n.t(k, scope: "activerecord.attributes.territorial_zone"), v] },
                 include_blank: false
        tz.input :code
      end
    end

    actions
  end
end
