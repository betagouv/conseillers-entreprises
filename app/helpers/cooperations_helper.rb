module CooperationsHelper
  # Options for a `select` tag with the viewable cooperations
  # Each option uses direct-submit-controller to automatically switch to its url.
  def options_for_managed_cooperations_select_menu(current_cooperation, cooperations)
    options = cooperations.map do |cooperation|
      action = policy(cooperation).send("#{action_name}?") ? action_name : "needs"
      path = polymorphic_path([action.to_sym, :conseiller, cooperation])
      [cooperation.name, cooperation.id, { data: { 'direct-submit-url': path } }]
    end

    options_for_select(options, current_cooperation.id)
  end
end
