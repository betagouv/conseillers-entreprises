class DiagnosisPolicy < ApplicationPolicy
  def show? = admin?

  def update? = admin?

  def new? = admin?

  def create? = admin?

  alias contact? show?
  alias needs? show?
  alias matches? show?

  alias update_contact? update?
  alias update_needs? update?
  alias update_matches? update?
  alias add_match? update?
end
