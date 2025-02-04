module ManagerFilters
  extend ActiveSupport::Concern

  def initialize_filters
    managed_antennes = current_user.managed_antennes
    # TODO : choisir quels filtres initialiser (région ou pas, par ex)
    @filters = {
      antennes: base_antennes,
      regions: managed_antennes.first.national? ? Territory.regions : Territory.where(id: managed_antennes.map(&:regions).flatten).uniq,
      themes: base_themes.uniq,
      subjects: base_subjects.uniq
    }
  end

  def load_filter_options
    render json: @filters.as_json
  end

  private

  def base_themes
    @base_themes = Theme.joins(subjects: :needs).where(subjects: { needs: base_needs_for_filters }).distinct.sort_by(&:label)
    @base_themes
  end

  def base_subjects
    @base_subjects = Subject.where(theme_id: base_themes.pluck(:id)).not_archived.order(:label)
    @base_subjects = @base_subjects.where(theme_id: params[:theme_id]) if params[:theme_id].present?
    @base_subjects
  end

  def base_antennes
    @base_antennes ||= BuildAntennesCollection.new(current_user).for_manager
  end
end
