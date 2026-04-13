class Stats::TeamPolicy < ApplicationPolicy
  def index? = @user&.is_admin? || @user&.is_sponsor?

  def public? = index?
  def needs? = index?
  def matches? = index?
  def acquisition? = index?
  def load_data? = index?
  def load_filter_options? = index?
end
