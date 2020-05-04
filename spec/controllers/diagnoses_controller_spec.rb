# frozen_string_literal: true

require 'rails_helper'
RSpec.describe DiagnosesController, type: :controller do
  login_user

  let(:diagnosis) { create :diagnosis, advisor: advisor }
  let(:archived_diagnosis) { create :diagnosis, :archived, advisor: advisor }
  let(:advisor) { current_user }
  let(:diagnosis_another_advisor) { create :diagnosis }

  describe 'GET #index' do
    subject(:request) { get :index }

    before do
      diagnosis
      archived_diagnosis
      diagnosis_another_advisor
    end

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'generates the active diagnoses list' do
      request
      expect(assigns(:diagnoses)).to contain_exactly(diagnosis)
    end
  end

  describe 'GET #processed' do
    let(:processed_diagnoses) { create :diagnosis_completed, advisor: advisor }

    subject(:request) { get :processed }

    before do
      diagnosis
      processed_diagnoses
      archived_diagnosis
      diagnosis_another_advisor
    end

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'generates the active diagnoses list' do
      request
      expect(assigns(:diagnoses)).to contain_exactly(processed_diagnoses)
    end
  end

  describe 'GET #archived' do
    subject(:request) { get :archives }

    before do
      diagnosis
      archived_diagnosis
    end

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'generates the archived diagnoses list' do
      request
      expect(assigns(:diagnoses)).to contain_exactly(archived_diagnosis)
    end
  end

  describe 'archival' do
    describe 'POST #archive' do
      before { post :archive, params: { id: diagnosis.id } }

      it('archives the diagnosis') { expect(diagnosis.reload.is_archived).to be_truthy }
      it('redirects to index') { expect(response).to redirect_to diagnoses_path }
    end

    describe 'POST #unarchive' do
      before { post :unarchive, params: { id: archived_diagnosis.id } }

      it('unarchives the diagnosis') { expect(archived_diagnosis.reload.is_archived).to be_falsey }
      it('redirects to index') { expect(response).to redirect_to diagnoses_path }
    end
  end

  describe 'POST #create' do
    let(:params) { { diagnosis: { facility_attributes: facility_params } } }

    context 'with no facility data' do
      let(:facility_params) { { invalid: 'value' } }

      it 'returns an error' do
        post :create, params: params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with a facility siret' do
      let(:siret) { '12345678901234' }
      let(:facility_params) { { siret: siret } }
      let(:facility) { create(:facility, siret: siret) }

      before do
        allow(UseCases::SearchFacility).to receive(:with_siret_and_save).with(siret) { facility }
      end

      it 'fetches info for ApiEntreprise and creates the diagnosis' do
        post :create, params: params

        expect(UseCases::SearchFacility).to have_received(:with_siret_and_save).with(siret)
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(needs_diagnosis_path(Diagnosis.last))
      end
    end

    context 'with manual facility info' do
      let(:insee_code) { '78586' }
      let(:facility_params) { { insee_code: insee_code, company_attributes: { name: 'analyse sans siret' } } }

      before do
        city_json = JSON.parse(file_fixture('geo_api_communes_78586.json').read)
        allow(ApiAdresse::Query).to receive(:city_with_code).with(insee_code) { city_json }
      end

      it "creates a new diagnosis without siret" do
        post :create, params: params

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to needs_diagnosis_path(Diagnosis.last)
      end
    end
  end
end
