module Reminders
  class NeedsController < BaseController
    before_action :setup_territory_filters, except: :send_last_chance_email
    before_action :find_current_territory, except: :send_last_chance_email
    before_action :collections_counts, except: :send_last_chance_email
    before_action :find_need, only: %i[send_last_chance_email send_abandoned_email send_reminder_email]

    def index
      redirect_to action: :poke
    end

    def poke
      render_collection(:poke, :action)
    end

    def recall
      render_collection(:recall, :action)
    end

    def will_be_abandoned
      render_collection(:will_be_abandoned, :action)
    end

    def not_for_me
      render_collection(:not_for_me, :status)
    end

    def send_last_chance_email
      @need.update(last_chance_email_sent_at: Time.zone.now)
      @needs_quo = @need.matches.status_quo
      @needs_quo.each do |match|
        ExpertMailer.last_chance(match.expert, @need, current_user).deliver_later
      end
      respond_to do |format|
        format.js
        format.html { redirect_to archive_reminders_needs_path, notice: t('mailers.emails_sent', count: @needs_quo.count) }
      end
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
        ExpertMailer.last_chance(match.expert, @need, current_user).deliver_now
      end
      respond_to do |format|
        format.js
        format.html { redirect_to critical_rate_reminders_experts_path, notice: t('mailers.email_sent') }
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
        .includes(:subject, :feedbacks, :company, :solicitation, reminder_feedbacks: { user: :antenne }, matches: { expert: :antenne })
        .order(:created_at)
        .page(params[:page])

      render :index
    end
  end
end
