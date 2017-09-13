# frozen_string_literal: true

module Api
  class ContactsController < ApplicationController
    def index
      visit = Visit.find params[:visit_id]
      check_access_to_visit(visit)
      @contacts = Contact.joins(:visits).where(visits: { id: visit.id })
    end

    def show
      @contact = Contact.find params[:id]
      check_access_to_contact(@contact)
    end

    def create
      visit = Visit.find params[:visit_id]
      check_access_to_visit(visit)
      @contact = UseCases::CreateContact.create_for_visit(contact_params: create_params, visit_id: visit.id)
      render :show, status: :created
    rescue StandardError
      render body: nil, status: :bad_request
    end

    def update
      @contact = Contact.find params[:id]
      check_access_to_contact(@contact)
      if @contact.update update_params
        render :show
      else
        render body: nil, status: :bad_request
      end
    end

    private

    def check_access_to_visit(visit)
      not_found unless visit.can_be_viewed_by?(current_user)
    end

    def check_access_to_contact(contact)
      not_found unless contact.can_be_viewed_by?(current_user)
    end

    def create_params
      params.require(:contact).permit(%i[full_name email phone_number role])
    end

    def update_params
      params.require(:contact).permit(%i[full_name email phone_number role])
    end
  end
end
