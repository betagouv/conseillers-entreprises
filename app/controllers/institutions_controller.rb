class InstitutionsController < ApplicationController
  before_action :retrieve_institution, except: :index

  layout 'side_menu', except: :index

  def index
    authorize Institution, :index?

    @institutions = Institution.all
      .order(:slug)
      .preload([institutions_subjects: :theme], [antennes: :communes], :advisors)

    @wide_layout = true
  end

  def show
    redirect_to action: :subjects
  end

  def subjects
  end

  private

  def retrieve_institution
    @institution = Institution.find_by(slug: params[:slug])
    authorize @institution

    @institutions_subjects = @institution.institutions_subjects
      .ordered_for_interview
      .preload(:subject, :theme, :experts_subjects)
  end
end
