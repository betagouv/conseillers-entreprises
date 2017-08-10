# frozen_string_literal: true

module UseCases
  class CreateContact
    class << self
      def create_for_visit(contact_params:, visit_id:)
        visit = Visit.find visit_id
        contact_params[:company_id] = visit.facility.company_id
        contact = Contact.create contact_params
        contact.save!
        visit.update visitee: contact
        contact
      end
    end
  end
end
