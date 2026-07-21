module CooperationsHelper
  # Build a `select` tag with the viewable cooperations
  # Each option uses direct-submit-controller to automatically switch to its url.
  def managed_cooperations_select_menu(current_cooperation)
    cooperations = policy_scope(Cooperation)
    return if cooperations.size < 2

    options = cooperations.map do |cooperation|
      action = policy(cooperation).send("#{action_name}?") ? action_name : "needs"
      path = polymorphic_path([action.to_sym, :conseiller, cooperation])
      [cooperation.name, cooperation.id, { data: { 'direct-submit-url': path } }]
    end

    select_tag("", options_for_select(options, current_cooperation.id), class: 'fr-select fr-mb-2v', data: { controller: "direct-submit", action: "direct-submit#submit" })
  end
end
