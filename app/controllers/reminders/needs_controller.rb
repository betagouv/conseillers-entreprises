module Reminders
  class NeedsController < BaseController
    before_action :setup_territory_filters
    before_action :find_current_territory
    before_action :collections_counts
    before_action :find_need, only: %i[send_abandoned_email send_reminder_email]

    def index
      redirect_to action: :poke
    end

    def poke
      render_collection(:poke, :action)
    end

    def recall
      render_collection(:recall, :action)
    end

    def last_chance
      render_collection(:last_chance, :action)
    end

    def not_for_me
      render_collection(:not_for_me, :status)
    end

    def send_abandoned_email
      ActiveRecord::Base.transaction do
        @need.update(abandoned_email_sent: true)
        CompanyMailer.abandoned_need(@need).deliver_later
      end
      respond_to do |format|
        format.js
        format.html { redirect_to archive_reminders_needs_path, notice: t('mailers.email_sent') }
      end
    end

    def send_reminder_email
      @feedback = Feedback.create(user: current_user, category: :need_reminder, description: t('.email_send'),
                                  feedbackable_type: 'Need', feedbackable_id: @need.id)
      @need.matches.status_quo.each do |match|
        ExpertMailer.positioning_rate_reminders(match.expert, current_user).deliver_later
      end
      respond_to do |format|
        format.js
        format.html { redirect_to critical_rate_reminders_experts_path, notice: t('mailers.email_sent') }
      end
    end

    def update_badges
      @need = Need.find(params.permit(:id)[:id])
      badges_params = params.require(:need).permit(badge_ids: [])
      unless @need.update(badges_params)
        flash.alert = @need.errors.full_messages.to_sentence
        redirect_back(fallback_location: poke_reminders_needs_path)
      end
    end

    private

    def find_need
      @need = Need.find(params.permit(:id)[:id])
    end

    def render_collection(name, category)
      case category
      when :action
        @needs = territory_needs.reminders_to(name)
      when :status
        @needs = territory_needs.where(status: name).archived(false)
      end
      @action = name
      @needs = @needs
        .joins(:matches, :experts)
        .includes(:subject, :feedbacks, :company, :solicitation, :badges, reminder_feedbacks: { user: :antenne }, matches: { expert: :antenne })
        .distinct
        .order(:created_at)
        .page(params[:page])

      render :index
    end
  end
end
