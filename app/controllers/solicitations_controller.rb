class SolicitationsController < PagesController
  def create
    @solicitation = Solicitation.create(solicitation_params.merge(retrieve_form_info))

    if !@solicitation.valid?
      @result = 'failure'
      @partial = 'solicitations/form'
      flash.alert = @solicitation.errors.full_messages.to_sentence
      return
    end

    @result = 'success'
    @partial = 'solicitations/thank_you'
    CompanyMailer.confirmation_solicitation(@solicitation.email).deliver_later
    AdminMailer.solicitation(@solicitation).deliver_later

    respond_to do |format|
      format.html { redirect_to landing_path(@solicitation.slug, anchor: "section-formulaire"), notice: t('.thanks') }
      format.js
    end
  end

  private

  def solicitation_params
    params.require(:solicitation)
      .permit(:description, :siret, :phone_number, :email, needs: {})
  end

  def retrieve_form_info
    form_info = session.delete(:solicitation_form_info)
    { form_info: form_info }
  end
end
