class CooperationPolicy < ApplicationPolicy
  def index? = @user&.is_admin? || @user&.is_cooperation_manager?

  def needs?
    @user&.is_admin? || @user&.managed_cooperations&.include?(@record)
  end

  def matches? = (@user&.is_admin? || @user&.managed_cooperations&.include?(@record)) && @record.display_matches_stats?

  def reports?
    @user&.is_admin? || @user&.managed_cooperations&.include?(@record)
  end

  def solicitations? = (@user&.is_admin? || @user&.managed_cooperations&.include?(@record)) && @record.wants_solicitations_export?

  alias load_filter_options? needs?
  alias provenance_detail_autocomplete? needs?
end
