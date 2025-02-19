module ManagerFilters
  extend ActiveSupport::Concern

  def initialize_filters(filter_keys)
    @filters = filter_keys.index_with do |key|
      send(:"base_#{key}").uniq
    end
  end

  def load_filter_options
    initialize_filters(dynamic_filter_keys)
    render json: @filters.as_json
  end

  private

  def base_themes
    @base_themes = Theme.joins(subjects: :needs).where(subjects: { needs: base_needs_for_filters }).distinct.sort_by(&:label)
    @base_themes
  end

  def base_subjects
    @base_subjects = Subject.where(theme: base_themes).not_archived.order(:label)
    @base_subjects = @base_subjects.where(theme_id: params[:theme_id]) if params[:theme_id].present?
    @base_subjects
  end

  def base_antennes
    @base_antennes ||= BuildAntennesCollection.new(current_user).for_manager
  end

  def base_regions
    return [] unless current_user.is_manager?
    managed_antennes = current_user.managed_antennes
    managed_antennes&.first&.national? ? Territory.regions : Territory.where(id: managed_antennes.map(&:regions).flatten).uniq
  end
end
