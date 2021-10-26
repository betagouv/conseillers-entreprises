# frozen_string_literal: true

class NeedsController < ApplicationController
  include Inbox
  before_action :retrieve_user_and_antenne, except: %i[index]
  before_action :retrieve_need, only: %i[show archive unarchive]

  layout 'side_menu', except: :show

  ## Collection actions
  # (aka “index pages”)
  # TODO: The collections rely on InvolvementConcern being used on User and Antenne.
  # We could simply have one route and get the name of the collection as a parameter, like this;
  # /besoins(/antenne)/:collection_name
  # However, Needs#show is already used to display the _completed diagnoses_, like this:
  # /besoins/:diagnosis_id
  # This is… sub-optimal. We might want to use Diagnoses#show for this; it is already used for in-progress diagnoses.
  # Note: We would still need to handle redirections, because the diagnoses paths are the ones sent by email to experts.
  # TODO: Another issue is that the collections in /besoins/ are actually collections of diagnoses.
  # All of this is #1278.
  def index
    redirect_to action: :quo
  end

  def quo
    retrieve_needs(current_user, :quo)
  end

  def taking_care
    retrieve_needs(current_user, :taking_care)
  end

  def done
    retrieve_needs(current_user, :done)
  end

  def not_for_me
    retrieve_needs(current_user, :not_for_me)
  end

  def expired
    retrieve_needs(current_user, :expired)
  end

  def antenne_quo
    retrieve_needs(current_user.antenne, :quo)
  end

  def antenne_taking_care
    retrieve_needs(current_user.antenne, :taking_care)
  end

  def antenne_done
    retrieve_needs(current_user.antenne, :done)
  end

  def antenne_not_for_me
    retrieve_needs(current_user.antenne, :not_for_me)
  end

  def antenne_expired
    retrieve_needs(current_user.antenne, :expired)
  end

  def search
    @recipient = current_user
    inbox_collections_counts(@recipient)
    @needs = @recipient
      .received_needs
      .omnisearch(search_params[:query])
      .includes(:company, :advisor, :subject)
      .order(created_at: :desc)
      .page(params[:page])
    render :index
  end

  private

  def retrieve_user_and_antenne
    @user = current_user
    @antenne = current_user.antenne
  end

  def search_params
    params.permit(:query)
  end

  ## Instance actions
  #
  public

  def show
    authorize @need
    @origin = params[:origin]
    @matches = @need.matches.order(:created_at)
  end

  def additional_experts
    @need = Need.find(params.require(:need))
    @query = params.require('query')&.strip

    @experts = Expert.omnisearch(@query)
      .with_subjects
      .where.not(id: @need.experts)
      .limit(20)
      .includes(:antenne, experts_subjects: :institution_subject)
  end

  def add_match
    @need = retrieve_need
    expert = Expert.find(params.require(:expert))
    @match = Match.create(need: @need, expert: expert, subject: @need.subject)
    if @match.valid?
      ExpertMailer.notify_company_needs(expert, @need).deliver_later
      expert.first_notification_help_email
    else
      flash.alert = @match.errors.full_messages.to_sentence
      redirect_back(fallback_location: root_path)
    end
  end

  def archive
    authorize @need, :archive?
    @need.archive!
    flash[:notice] = t('.subjet_achived')
    redirect_back fallback_location: diagnosis_path(@need.diagnosis),
                  notice: t('needs.archive.archive_done', company: @need.company.name)
  end

  def unarchive
    authorize @need, :archive?
    @need.update(archived_at: nil)
    flash[:notice] = t('.subject_unarchived')
    redirect_to diagnosis_path(@need.diagnosis)
  end

  private

  def retrieve_diagnosis
    Diagnosis.find(params.require(:id))
  end

  def retrieve_need
    @need = Need.find(params.require(:id))
  end
end
