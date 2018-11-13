ActiveAdmin.register Commune do
  menu parent: :territories, priority: 2
  includes :territories

  filter :insee_code
  filter :created_at
  filter :updated_at

  ## Show
  #
  show do
    attributes_table do
      row :insee_code
      row :created_at
      row :updated_at
      row(:territories) { |c| safe_join(c.territories.map { |t| link_to t, admin_territory_path(t) }, ', '.html_safe) }
      row(:antennes) { |c| safe_join(c.antennes.map { |a| link_to a, admin_antenne_path(a) }, ', '.html_safe) }
      row(:direct_experts) { |c| safe_join(c.direct_experts.map { |e| link_to e, admin_expert_path(e) }, ', '.html_safe) }
    end
  end
end
