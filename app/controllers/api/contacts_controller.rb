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
      @contact = UseCases::CreateContact.create_for_visit(contact_params: create_params, visit_id: params[:visit_id])
      render :show, status: :created
    rescue StandardError
      render body: nil, status: :bad_request
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

    private

    def create_params
      params.require(:contact).permit(%i[full_name email phone_number role])
    end

    def update_params
      params.require(:contact).permit(%i[full_name email phone_number role])
    end
  end
end
