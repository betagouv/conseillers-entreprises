# frozen_string_literal: true

module Api
  class ContactsController < ApplicationController
    def index
      @contacts = Contact.joins(:visits).where(visits: { id: params[:visit_id] })
    end

    def show
      @contact = Contact.find params[:id]
    end

    def create
      visit = Visit.find params[:visit_id]
      params = create_params.merge!(company_id: visit.facility.company_id)
      @contact = Contact.create params
      if @contact.save
        visit.update visitee: @contact
        render :show, status: :created
      else
        render body: nil, status: :bad_request
      end
    end

    def update
      @contact = Contact.find params[:id]
      if @contact.update update_params
        render :show
      else
        render body: nil, status: :bad_request
      end
    end

    def destroy
      contact = Contact.find params[:id]
      if contact.destroy
        render body: nil, status: :ok
      else
        render body: nil, status: :unprocessable_entity
      end
    end

    def contact_button_expert
      @visit = Visit.find params[:visit_id]
      @assistance = Assistance.find params[:assistance_id]
      @expert = Expert.find params[:expert_id]
      @question = @assistance.question
    end

    private

    def create_params
      params.require(:contact).permit(%i[full_name email phone_number role])
    end

    def update_params
      params.require(:contact).permit(%i[full_name email phone_number role])
    end
  end
end
