# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'mailers/expert_mailer/notify_company_needs.html.haml', type: :view do
  context 'hash with several information' do
    let(:expert) { create :expert }
    let(:user) { create :user }
    let(:question) { create :question }
    let(:diagnosis) { create :diagnosis, visit: visit }

    let(:params_hash) do
      {
        visit_date: visit.happened_on_localized,
        diagnosis_id: diagnosis.id,
        company_name: visit.company_name,
        company_contact: visit.visitee,
        questions_with_needs_description: questions_with_needs_description,
        advisor: user
      }
    end

    before { assign(:params, params_hash) }

    context 'when visit has a date, contact has phone number, there is an access token and there are two questions' do
      let(:contact) { create :contact, :with_phone_number }
      let(:visit) { create :visit, :with_visitee, :with_date, advisor: user, visitee: contact }
      let(:other_question) { create :question }
      let(:questions_with_needs_description) do
        [
          { question: question, need_description: 'Help this company' },
          { question: other_question, need_description: 'You can ignore this' }
        ]
      end

      before do
        assign(:access_token, 'random_access_token')
        render
      end

      it 'displays the date, phone number and 2 list items' do
        expect(rendered).to match(%r{le [0-9]{2}/[0-9]{2}/20[0-9]{2}})
        expect(rendered).to include "joignable au #{contact.phone_number}"
        expect(rendered).to include "experts/diagnoses/#{diagnosis.id}"
        assert_select 'li', count: 2
      end
    end

    context 'when visit has no date, contact has no phone number, there is no access token and there is one question' do
      let(:contact) { create :contact, :with_email }
      let(:visit) { create :visit, :with_visitee, advisor: user, visitee: contact }
      let(:questions_with_needs_description) { [{ question: question, need_description: 'Help this company' }] }

      before do
        assign(:access_token, nil)
        render
      end

      it 'does not display the date, but displays email and one list item' do
        expect(rendered).not_to match(%r{le [0-9]{2}/[0-9]{2}/20[0-9]{2}})
        expect(rendered).to include "joignable à l’adresse e-mail #{contact.email}"
        expect(rendered).to include "territory_users/diagnoses/#{diagnosis.id}"
        assert_select 'li', count: 1
      end
    end
  end
end
