module SearchHelper
  def build_collection_for_select
    # Build a collection_for_select with a list of subjects ordered by themes
    themes_and_subjects_collection = possible_themes_subjects_collection
    option_groups_from_collection_for_select(themes_and_subjects_collection[:themes],
                                             :subjects_ordered_for_interview,
                                             :label,
                                             :id, -> (subject) { themes_and_subjects_collection[:subjects][subject.id] },
                                             needs_search_params[:by_subject])
  end
end
