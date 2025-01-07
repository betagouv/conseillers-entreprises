module LoadFilterOptions
  extend ActiveSupport::Concern

  def load_filter_options
    response = {
      antennes: @institution_antennes,
      themes: @themes,
      subjects: @subjects.select(:id, :label)
    }

    render json: response.as_json
  end

  private

  def init_filters
    @iframes = Landing.iframe.not_archived.order(:slug)
    @apis = Landing.api.not_archived.order(:slug)
    @institution_antennes = []
    @themes = Theme.for_interview
    @subjects = Subject.not_archived.for_interview

    if params[:institution].present?
      institution = Institution.find(params[:institution])
      @institution_antennes = build_institution_antennes_collection(institution)
      @themes = @themes.merge(institution.themes).select(:id, :label).order(:label).uniq
      @subjects = @subjects.merge(institution.subjects.not_archived.order(:label))
    end
    # on verifie que le theme précédemment sélectionné fait bien partie des thèmes de l'institution
    if params[:theme].present? && @themes.map(&:id).include?(params[:theme].to_i)
      @subjects = @subjects.where(theme_id: params[:theme])
    end
  end

  def build_institution_antennes_collection(institution)
    institution_antennes = institution.antennes.not_deleted
    antennes_collection = antennes_collection_hash(institution_antennes, institution_antennes)

    add_locals_antennes(antennes_collection, institution_antennes)
  end
end
