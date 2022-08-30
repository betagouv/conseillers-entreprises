module Reminders
  class NeedsController < BaseController
    before_action :setup_territory_filters, except: :send_abandoned_email
    before_action :find_current_territory, except: :send_abandoned_email
    before_action :collections_counts, except: :send_abandoned_email

    def index
      redirect_to action: :poke
    end

    def poke
      render_collection(:poke)
    end

    def recall
      render_collection(:recall)
    end

    def will_be_abandoned
      render_collection(:will_be_abandoned)
    end

    def archive
      render_collection(:archive)
    end

    def send_abandoned_email
      @need = Need.find(params.permit(:id)[:id])
      @need.update(abandoned_email_sent: true)
      CompanyMailer.abandoned_need(@need).deliver_later
      respond_to do |format|
        format.js
        format.html { redirect_to archive_reminders_needs_path, notice: t('mailers.email_sent') }
      end
    end

    private

    def render_collection(action)
      @needs = territory_needs
        .reminders_to(action)
        .includes(:subject, :feedbacks, :company, :solicitation, reminder_feedbacks: { user: :antenne }, matches: { expert: :antenne })
        .order(:created_at)
        .page(params[:page])

      @action = action
      render :index
    end
  end
end
