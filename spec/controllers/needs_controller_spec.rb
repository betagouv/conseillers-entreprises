require 'rails_helper'

RSpec.describe NeedsController do
  login_user

  describe 'needs inboxes' do
    describe 'GET #index' do
      subject(:request) { get :index }

      it 'returns http success' do
        expect(response).to be_successful
      end
    end

    describe 'GET #archives' do
      subject(:request) { get :archives }

      it 'returns http success' do
        expect(response).to be_successful
      end
    end
  end

  describe 'GET #show' do
    subject(:request) { get :show, params: { id: diagnosis.id } }

    let(:diagnosis) { create :diagnosis }

    context 'current user is an expert' do
      let!(:expert) { create :expert, users: [current_user] }

      context 'user is contacted for diagnosis' do
        before do
          create(:match,
                 expert: expert,
                 need: create(:need,
                              diagnosis: diagnosis))
        end

        it('returns http success') { expect(response).to be_successful }
      end
    end
  end

  describe '#add_expert' do
    let(:need) { create(:need) }
    let(:request) { post :add_match, params: { id: need.id, expert_id: expert_id, format: :js } }

    context 'when user is admin and expert is present' do
      login_admin
      let(:expert) { create(:expert) }
      let(:expert_id) { expert.id }

      it 'adds an expert to the need' do
        request
        expect(response).to have_http_status(:success)
        expect(need.experts).to include(expert)
      end
    end

    context 'when user is admin and expert is not present' do
      login_admin
      let(:expert_id) { '' }

      it 'does not add an expert if expert_id is nil' do
        request
        expect(response).to have_http_status(:unprocessable_content)
        expect(need.experts).to be_empty
      end
    end

    context 'when user is not admin' do
      login_user
      let(:expert) { create(:expert) }
      let(:expert_id) { expert.id }

      it 'does not add an expert' do
        expect { request }.to raise_error(Pundit::NotAuthorizedError)
        expect(need.experts).not_to include(expert)
      end
    end
  end

  describe 'POST #star' do
    login_admin

    let(:need) { create(:need, starred_at: nil) }

    subject(:request) { post :star, params: { id: need.id, format: :js } }

    it 'stars the need' do
      request
      expect(response).to have_http_status(:success)
      expect(need.reload.starred_at).not_to be_nil
    end
  end

  describe 'POST #unstar' do
    login_admin

    let(:need) { create(:need, starred_at: Time.zone.now) }

    subject(:request) { post :unstar, params: { id: need.id, format: :js } }

    it 'unstars the need' do
      request
      expect(response).to have_http_status(:success)
      expect(need.reload.starred_at).to be_nil
    end
  end

  describe 'filters' do
    let!(:expert) { create :expert, users: [current_user] }
    let!(:theme1) { create :theme, label: 'Theme 1' }
    let!(:theme2) { create :theme, label: 'Theme 2' }
    let!(:subject1) { create :subject, theme: theme1, label: 'Subject 1' }
    let!(:subject2) { create :subject, theme: theme2, label: 'Subject 2' }
    let!(:need1) { create :need, subject: subject1 }
    let!(:need2) { create :need, subject: subject2 }

    before do
      create :match, expert: expert, need: need1, status: :quo
      create :match, expert: expert, need: need2, status: :quo
    end

    describe 'GET #quo_active with filters' do
      subject(:request) { get :quo_active }

      before { request }

      it 'initializes filters' do
        expect(assigns(:filters)).not_to be_nil
        expect(assigns(:filters)[:themes]).not_to be_empty
        expect(assigns(:filters)[:subjects]).not_to be_empty
      end

      it 'includes available themes' do
        theme_labels = assigns(:filters)[:themes].map(&:label)

        expect(theme_labels).to include('Theme 1', 'Theme 2')
      end

      it 'includes available subjects' do
        subject_labels = assigns(:filters)[:subjects].map(&:label)

        expect(subject_labels).to include('Subject 1', 'Subject 2')
      end
    end

    describe 'GET #load_filter_options' do
      subject(:request) { get :load_filter_options }

      before { request }

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'returns JSON' do
        expect(response.content_type).to include('application/json')
      end

      it 'returns subjects' do
        json_response = response.parsed_body

        expect(json_response).to have_key('subjects')
      end

      context 'with theme_id parameter' do
        subject(:request) { get :load_filter_options, params: { theme_id: theme1.id } }

        it 'filters subjects by theme' do
          json_response = response.parsed_body
          subject_labels = json_response['subjects'].pluck('label')

          expect(subject_labels).to include('Subject 1')
          expect(subject_labels).not_to include('Subject 2')
        end
      end
    end
  end
end
