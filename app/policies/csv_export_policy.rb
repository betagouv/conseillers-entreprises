class CsvExportPolicy < ApplicationPolicy
  def index?
    @user&.is_admin?
  end

  def download?
    @user&.is_admin?
  end
end
