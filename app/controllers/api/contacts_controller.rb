# frozen_string_literal: true

module Api
  class ContactsController < ApplicationController

    def show
      @contact = Contact.find params[:id]
    end

    def index
      @contacts = Contact.joins(:visits).where(visits: { id: visit_id_param })
    end

    def create
      visit = Visit.find visit_id_param
      params = create_params.merge!(company_id: visit.facility.company_id)
      @contact = Contact.create(params)
      if @contact.save!
        render :show
      else
        render status: :bad_request
      end
    end

    def update
      @contact = Contact.find params[:id]
      render status: 500 unless @contact.update(update_params)
    end

    def destroy
      contact = Contact.find params[:id]
      render status: :bad_request unless contact.destroy!
    end

    def contact_button_expert
      @visit = Visit.find params[:visit_id]
      @assistance = Assistance.find params[:assistance_id]
      @question = @assistance.question
      @expert = Expert.find params[:expert_id]
    end

    private

    def create_params
      params.require(:contact).permit(%i[full_name email phone_number role company_id])
    end

    def update_params
      params.require(:contact).permit(%i[full_name email phone_number role])
    end

    def visit_id_param
      params.require(:visit_id)
    end
  end
end
