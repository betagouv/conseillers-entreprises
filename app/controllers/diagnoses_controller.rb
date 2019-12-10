# frozen_string_literal: true

class DiagnosesController < ApplicationController
  before_action :retrieve_diagnosis, only: %i[show archive unarchive step2 besoins step3 visite step4 selection]

  def index
    @diagnoses = sent_diagnoses(current_user, archived: false)
  end

  def index_antenne
    @diagnoses = sent_diagnoses(current_user.antenne, archived: false)
  end

  def archives
    @diagnoses = sent_diagnoses(current_user, archived: true)
  end

  def archives_antenne
    @diagnoses = sent_diagnoses(current_user.antenne, archived: true)
  end

  def show
    authorize @diagnosis
    if @diagnosis.completed?
      redirect_to need_path(@diagnosis)
    else
      redirect_to action: "step#{@diagnosis.step}", id: @diagnosis
    end
  end

  def archive
    @diagnosis.archive!
    redirect_to diagnoses_path
  end

  def unarchive
    @diagnosis.unarchive!
    redirect_to diagnoses_path
  end

  def step2
    @themes = Theme.ordered_for_interview
  end

  def besoins
    diagnosis_params = params.require(:diagnosis).permit(:content,
                                                         needs_attributes: [:_destroy, :content, :subject_id, :id])
    diagnosis_params[:step] = 3
    authorize @diagnosis, :update?
    if @diagnosis.update(diagnosis_params)
      redirect_to action: :step3, id: @diagnosis
    else
      flash.alert = @diagnosis.errors.full_messages.to_sentence
      respond_to do |format|
        format.js { render 'application/flashes' }
        format.html do
          @themes = Theme.all.includes(:subjects)
          render action: :step2
        end
      end
    end
  end

  def step3; end

  def visite
    diagnosis_params = params_for_visite
    diagnosis_params[:visitee_attributes][:company_id] = @diagnosis.facility.company.id
    diagnosis_params[:step] = 4
    authorize @diagnosis, :update?
    if @diagnosis.update(diagnosis_params)
      redirect_to action: :step4, id: @diagnosis
    else
      flash.alert = @diagnosis.errors.full_messages.to_sentence
      respond_to do |format|
        format.js { render 'application/flashes' }
        format.html { render action: :step3 }
      end
    end
  end

  def step4; end

  def selection
    if @diagnosis.match_and_notify!(params_for_matches)
      flash.notice = I18n.t('diagnoses.step5.notifications_sent')
      redirect_to need_path(@diagnosis)
    else
      flash.alert = @diagnosis.errors.full_messages.to_sentence
      respond_to do |format|
        format.js { render 'application/flashes' }
        format.html { render action: :step4, status: :bad_request }
      end
    end
  end

  private

  def sent_diagnoses(model, archived:)
    model.sent_diagnoses.archived(archived).order(created_at: :desc)
      .distinct
      .left_outer_joins(:matches,
                        needs: :matches)
      .includes(:matches,
                :visitee, facility: :company,
        needs: :matches)
  end

  def params_for_visite
    permitted = params.require(:diagnosis).permit(:happened_on, visitee_attributes: [:full_name, :role, :email, :phone_number, :id])
    permitted
  end

  def params_for_matches
    matches = params.permit(matches: {}).require(:matches)
    matches.transform_values do |expert_subjects_selection|
      expert_subjects_selection.select{ |_,v| v == '1' }.keys
    end
  end

  def retrieve_diagnosis
    safe_params = params.permit(:id)
    @diagnosis = Diagnosis.find(safe_params[:id])
  end
end
