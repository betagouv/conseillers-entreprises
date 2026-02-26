module SearchFilters
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
    @base_themes ||= Theme.joins(subjects: :needs)
      .merge(Subject.not_archived)
      .where(subjects: { needs: base_needs_for_filters })
      .distinct
      .sort_by(&:label)
  end

  def base_subjects
    @base_subjects ||= begin
      authorized_theme_id = params[:theme_id].presence&.to_i
      theme_filter = if authorized_theme_id && base_themes.map(&:id).include?(authorized_theme_id)
        authorized_theme_id
      else
        base_themes
      end

      Subject.where(theme: theme_filter).not_archived.order(:label)
    end
  end

  def base_cooperations
    @base_cooperations ||= Cooperation.external.joins(:needs).where(needs: base_needs_for_filters).distinct.order(:name)
  end

  def base_antennes
    @base_antennes ||= BuildAntennesCollection.new(current_user).for_manager
  end

  def base_regions
    return [] unless current_user.is_manager?
    managed_antennes = current_user.managed_antennes
    managed_antennes&.first&.national? ? RegionOrderingService.call : managed_antennes.map(&:regions).flatten.uniq
  end

  # Default implementations that can be overridden in controllers
  def all_filter_keys
    [:themes, :subjects]
  end

  def dynamic_filter_keys
    [:subjects]
  end

  def default_antenne_id
    return if params[:antenne_id].present?
    # Prefer the aggregated entry (with "locales") when it exists
    params[:antenne_id] = @base_antennes.find { |a| a[:id].to_s.include?('locales') }&.dig(:id)&.to_s ||
                          @base_antennes.first&.dig(:id)&.to_s
  end
end
