require 'rails_helper'

RSpec.describe SolicitationsController do
  describe 'POST #create' do
    let(:landing) { create(:landing) }
    let(:landing_subject) { create(:landing_subject) }
    let(:request) do
  post :create,
       params: {
         landing_slug: landing.slug, landing_subject_slug: landing_subject.slug,
             solicitation: { full_name: full_name, email: email, phone_number: phone_number, landing_id: landing.id, landing_subject_id: landing_subject.id }
       }
end

    context 'with good params' do
      let(:full_name) { 'Louise Michel' }
      let(:email) { 'louise@michel.org' }
      let(:phone_number) { '0606060606' }

      it 'creates a solicitation' do
        request
        solicitation = Solicitation.last
        expect(solicitation.full_name).to eq('Louise Michel')
        expect(solicitation.status).to eq('step_company')
      end
    end
  end

  describe 'PATCH #update_step_company' do
    let(:solicitation) { create(:solicitation, full_name: "L Michel", email: 'l@michel.org', phone_number: 'xx', status: 'step_company', siret: nil) }
    let(:request) { patch :update_step_company, params: { uuid: solicitation.uuid, solicitation: { siret: siret } } }

    context 'with blank siret' do
      let(:siret) { "       " }

      it "invalidates solicitation" do
        request
        expect(solicitation.siret).to be_nil
        expect(solicitation.reload.status).to eq('step_company')
      end
    end

    context 'with incorrect siret' do
      let(:siret) { "123 456 789 00011" }

      it "invalidates solicitation" do
        request
        expect(solicitation.siret).to be_nil
        expect(solicitation.reload.status).to eq('step_company')
      end
    end

    context 'with correct siret' do
      let(:siret) { "41816609600069" }

      it "updates solicitation" do
        request
        expect(solicitation.reload.siret).to eq("41816609600069")
        expect(solicitation.status).to eq('step_description')
      end
    end
  end

  describe 'GET #redirect_to_solicitation_step' do
    subject(:request) { get :redirect_to_solicitation_step, params: { uuid: solicitation.uuid, relaunch: 'relance-sollicitation' } }

    let!(:solicitation) { create :solicitation, full_name: "JJ Goldman", email: 'test@example.com', phone_number: 'xx', completed_at: nil, status: status, siret: siret }

    context 'step_company solicitation' do
      let(:status) { :step_company }
      let(:siret) { nil }

      it 'returns http success' do
        expect(response).to be_successful
      end
    end

    context 'step_description solicitation' do
      let!(:solicitation) { create :solicitation, full_name: "JJ Goldman", email: 'test@example.com', phone_number: 'xx', completed_at: nil, status: :step_description, siret: '41816609600069' }

      it 'returns http success' do
        expect(response).to be_successful
      end
    end
  end
end
