## Support for :archive and :unarchive actions in /admin
#
module DynamicallyFiltrable
  extend ActiveSupport::Concern

  def init_landing_subjects_filter
    @landing_themes = if params[:q].present? && params[:q][:landing_id_eq].present?
      Landing.find(params[:q][:landing_id_eq]).landing_themes.not_archived
    else
      LandingTheme.not_archived
    end
    @landing_subjects = if params[:q].present? && param_landing_theme_id.present?
      LandingTheme.find(param_landing_theme_id).landing_subjects.not_archived
    else
      LandingSubject.not_archived
    end
  end

  def init_subjects_filter
    @subjects = if params[:q].present? && param_theme_id.present?
      Theme.find(param_theme_id).subjects.not_archived
    else
      Subject.not_archived
    end
  end

  def init_antennes_filter
    @antennes_collection = if params[:q].present? && params[:q][:advisor_institution_id_eq].present?
      Antenne.where(institution_id: params[:q][:advisor_institution_id_eq])
    else
      Antenne.all
    end
  end

  private

  # Suivant le nom de la relation dans le model, le nom du param change
  def param_landing_theme_id
    (params[:q][:landing_subject_landing_theme_id_eq] || params[:q][:landing_theme_id_eq])
  end

  def param_theme_id
    (params[:q][:subject_theme_id_eq] || params[:q][:theme_id_eq] || params[:q][:theme_eq] || params[:q][:themes_id_eq])
  end
end
