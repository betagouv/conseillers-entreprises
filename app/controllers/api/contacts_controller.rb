# frozen_string_literal: true

module Api
  class ContactsController < ApplicationController
    def show
      @contact = Contact.find params[:id]
    end

    def index
      @contacts = Contact.where(company_id: index_params)
    end

    def create
      @contact = Contact.create(create_params)
      render :show
    end

    def update
      @contact = Contact.find params[:id]
      render status: 500 unless @contact.update(update_params)
    end

    def destroy
      contact = Contact.find params[:id]
      render status: :bad_request unless contact.destroy!
    end

    private

    def create_params
      params.require(:contact).permit(%i[full_name email phone_number role company_id])
    end

    def update_params
      params.require(:contact).permit(%i[full_name email phone_number role])
    end

    def index_params
      params.require(:company_id)
    end
  end
end
