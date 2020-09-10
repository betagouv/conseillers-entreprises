class CompanySatisfactionsController < PagesController
  def new
    need = Need.find(params[:besoin])
    satisfaction = CompanySatisfaction.find_by(need: need)
    email_token = Digest::SHA256.hexdigest(need.diagnosis.visitee.email)
    if satisfaction.present?
      flash.notice = t('.company_satisfaction_exist')
      redirect_to root_path
    elsif need.nil? || email_token != params[:token]
      redirect_to root_path
    end
    @company_satisfaction = CompanySatisfaction.new(need: need)
  end

  def create
    @company_satisfaction = CompanySatisfaction.new(satisfaction_params)
    if @company_satisfaction.save
      redirect_to thank_you_company_satisfactions_path
    else
      redirect_to action: :new, alert: @company_satisfaction.errors.full_messages.to_sentence
    end
  end

  def thank_you; end

  private

  def satisfaction_params
    params.require(:company_satisfaction).permit(:need_id, :contacted_by_expert, :useful_exchange, :comment)
  end
end
