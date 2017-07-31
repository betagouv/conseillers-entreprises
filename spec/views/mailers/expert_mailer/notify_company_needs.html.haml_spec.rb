# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'mailers/expert_mailer/notify_company_needs.html.haml', type: :view do
  context 'hash with several information' do
    let(:expert) { create :expert }
    let(:user) { create :user }

    let(:params_hash) do
      {
        visit_date: visit.happened_at_localized,
        company_name: visit.company_name,
        company_contact: visit.visitee,
        assistances: assistances,
        advisor: user,
        expert_institution: expert.institution.name
      }
    end

    before do
      assign(:params, params_hash)
      render
    end

    context 'when visit has a date, contact has phone number, and there are two assistances' do
      let(:contact) { create :contact, :with_phone_number }
      let(:visit) { create :visit, :with_visitee, :with_date, advisor: user, visitee: contact }
      let(:assistances) { create_list :assistance, 2 }

      it 'displays the date, phone number and 2 list items' do
        expect(rendered).to include visit.happened_at_localized
        expect(rendered).to include "joignable au #{contact.phone_number}"
        assert_select 'li', count: 2
      end
    end

    context 'when visit has no date, contact has no phone number, and there is one assistance' do
      let(:contact) { create :contact, :with_email }
      let(:visit) { create :visit, :with_visitee, advisor: user, visitee: contact }
      let(:assistances) { create_list :assistance, 1 }

      it 'does not display the date, and displays email and one list item' do
        expect(rendered).not_to include 'a visité le'
        expect(rendered).to include "joignable au #{contact.email}"
        assert_select 'li', count: 1
      end
    end
  end
end
