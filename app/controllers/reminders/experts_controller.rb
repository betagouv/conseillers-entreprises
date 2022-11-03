module Reminders
  class ExpertsController < BaseController
    include Inbox
    helper_method :inbox_collections_counts
    before_action :setup_territory_filters, :find_current_territory, :collections_counts, only: %i[index show critical_rate worrying_rate pending_rate]
    before_action :retrieve_expert, except: %i[index critical_rate worrying_rate pending_rate]

    def index
      redirect_to action: :critical_rate
    end

    def critical_rate
      render_collection(:critical_rate)
    end

    def worrying_rate
      render_collection(:worrying_rate)
    end

    def pending_rate
      render_collection(:pending_rate)
    end

    def quo_active
      retrieve_needs(@expert, :quo_active, view: :quo)
    end

    def taking_care
      retrieve_needs(@expert, :taking_care, view: :quo)
    end

    def done
      retrieve_needs(@expert, :done, view: :quo)
    end

    def not_for_me
      retrieve_needs(@expert, :not_for_me, view: :quo)
    end

    def quo_abandoned
      retrieve_needs(@expert, :quo_abandoned, view: :quo)
    end

    def show
      @action = :critical_rate
    end

    def send_reminder_email
      @expert = Expert.find(params.permit(:id)[:id])
      ExpertMailer.positioning_rate_reminders(@expert, current_user).deliver_later
      @feedback = Feedback.create(user: current_user, category: :expert_reminder, description: t('.email_send'), feedbackable_type: 'Expert', feedbackable_id: @expert.id)
      respond_to do |format|
        format.js
        format.html { redirect_to critical_rate_reminders_experts_path, notice: t('mailers.email_sent') }
      end
    end

    private

    def safe_params
      params.permit(:id)
    end

    def retrieve_expert
      @expert = Expert.find(safe_params[:id])
    end

    def render_collection(action)
      @active_experts = PositionningRate::Collection.new(territory_experts).send(action)
        .includes(:antenne, :reminder_feedbacks, :users, :received_needs)
        .most_needs_quo_first
        .page params[:page]

      @action = action
      render :index
    end
  end
end
