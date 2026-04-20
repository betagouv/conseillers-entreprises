class Stats::TeamPolicy < ApplicationPolicy
  def index? = @user&.is_admin? || @user&.is_sponsor?

  def public? = index?
  def needs? = index?
  def matches? = index?
  def acquisition? = index?
  def load_data? = index?
  def load_filter_options? = index?

  def visible_institutions
    institutions = if @user&.is_admin?
      Institution.all
    elsif @user&.is_sponsor?
      @user.sponsored_institutions
    else
      Institution.none
    end
    institutions.not_deleted.expert_provider
  end
end
