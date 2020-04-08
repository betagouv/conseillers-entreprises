# frozen_string_literal: true

require 'rails_helper'
RSpec.describe DiagnosesController, type: :controller do
  login_user

  let(:diagnosis) { create :diagnosis, advisor: advisor }
  let(:archived_diagnosis) { create :diagnosis, :archived, advisor: advisor }
  let(:advisor) { current_user }

  describe 'GET #index' do
    subject(:request) { get :index }

    before do
      diagnosis
      archived_diagnosis
    end

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'generates the active diagnoses list' do
      request
      expect(assigns(:diagnoses)).to contain_exactly(diagnosis)
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

  describe 'POST #create_diagnosis_without_siret' do
    let(:params) { { city: 'Sartrouville', postal_code: '78500', name: 'annalyse sans siret' } }
    let(:url) { "https://api-adresse.data.gouv.fr/search/?postcode=78500&q=Sartrouville&type=municipality" }
    let(:headers) { { 'Connection': 'close', 'Host': 'api-adresse.data.gouv.fr', 'User-Agent': /http\.rb.*/ } }

    before do
      stub_request(:get, url).with(headers: headers).to_return(
        status: 200, headers: {},
        body: File.read(Rails.root.join('spec', 'fixtures', 'api_adresse_200.json'))
      )
    end

    it "creates a new diagnosis without siret" do
      post :create_diagnosis_without_siret, params: params
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to needs_diagnosis_path(Diagnosis.last)
    end
  end
end
