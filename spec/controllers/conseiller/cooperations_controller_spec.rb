require 'rails_helper'

RSpec.describe Conseiller::CooperationsController do
  login_user

  let(:cooperation) { create :cooperation, root_url: 'https://exemple.fr', display_matches_stats: true }
  let!(:user_right) { create :user_right, category: :cooperation_manager, user: current_user, rightable_element: cooperation }
  let(:solicitation) { create :solicitation, mtm_campaign: 'entreprendre', mtm_kwd: 'F1111', cooperation: cooperation }

  describe 'GET #needs' do
    it do
      get :needs, params: { id: cooperation.id }
      expect(response).to be_successful
      expect(assigns(:cooperation)).to eq(cooperation)
    end
  end

  describe 'GET #matches' do
    let(:other_institution) { create :institution }

    context 'with a cooperation manager from another institution' do
      it 'only shows the matches of the current user institution' do
        get :matches, params: { id: cooperation.id }
        expect(response).to be_successful
        expect(assigns(:filters)[:institutions]).to eq([current_user.institution])
        expect(assigns(:filters)[:include_blank_institution]).to be(false)
        expect(assigns(:stats_params)[:institution_id]).to eq(current_user.institution.id)
      end

      it 'ignores the requested institution' do
        get :matches, params: { id: cooperation.id, institution_id: cooperation.institution.id }
        expect(assigns(:stats_params)[:institution_id]).to eq(current_user.institution.id)
      end
    end

    context 'with two cooperation managers from different institutions' do
      let(:other_manager) { create :user, antenne: create(:antenne, institution: other_institution) }

      before { create :user_right, category: :cooperation_manager, user: other_manager, rightable_element: cooperation }

      it 'filters each one on its own institution' do
        get :matches, params: { id: cooperation.id }
        expect(assigns(:stats_params)[:institution_id]).to eq(current_user.institution.id)

        sign_in other_manager
        get :matches, params: { id: cooperation.id }
        expect(assigns(:stats_params)[:institution_id]).to eq(other_institution.id)
      end
    end

    context 'with a sponsor' do
      let(:sponsored_institutions) { create_list :institution, 2 }

      before do
        sponsored_institutions.each do |institution|
          create :user_right, category: :sponsor, user: current_user, rightable_element: institution
        end
      end

      it 'lists the sponsored institutions and defaults to the first one' do
        get :matches, params: { id: cooperation.id }
        expect(assigns(:filters)[:institutions]).to match_array(sponsored_institutions)
        expect(assigns(:filters)[:include_blank_institution]).to be(false)
        expect(assigns(:stats_params)[:institution_id]).to eq(assigns(:filters)[:institutions].first.id)
      end

      it 'allows selecting a sponsored institution' do
        get :matches, params: { id: cooperation.id, institution_id: sponsored_institutions.last.id }
        expect(assigns(:stats_params)[:institution_id]).to eq(sponsored_institutions.last.id)
      end

      it 'ignores an institution outside the sponsored ones' do
        get :matches, params: { id: cooperation.id, institution_id: other_institution.id }
        expect(assigns(:stats_params)[:institution_id]).to eq(assigns(:filters)[:institutions].first.id)
      end
    end

    context 'with an admin' do
      let(:admin) { create :user, :admin }

      before { sign_in admin }

      it 'lists the cooperation and managers institutions' do
        get :matches, params: { id: cooperation.id }
        expect(assigns(:filters)[:institutions]).to contain_exactly(cooperation.institution, current_user.institution)
        expect(assigns(:filters)[:include_blank_institution]).to be(true)
        expect(assigns(:stats_params)[:institution_id]).to be_nil
      end

      it 'allows selecting a listed institution' do
        get :matches, params: { id: cooperation.id, institution_id: current_user.institution.id }
        expect(assigns(:stats_params)[:institution_id]).to eq(current_user.institution.id)
      end

      it 'ignores an institution outside the listed ones' do
        get :matches, params: { id: cooperation.id, institution_id: other_institution.id }
        expect(assigns(:stats_params)[:institution_id]).to be_nil
      end
    end
  end
end
