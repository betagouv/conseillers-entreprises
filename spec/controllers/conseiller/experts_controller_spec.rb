require 'rails_helper'

RSpec.describe Conseiller::ExpertsController do
  login_admin

  describe 'GET #index' do
    let(:institution) { create :institution, name: 'Direction Générale des Finances Publiques (DGFIP)' }
    let(:antenne_44) { create :antenne, name: 'DDFIP 44 Loire Atlantique', institution: institution }
    let(:antenne_other) { create :antenne, name: 'DDFIP 62', institution: institution }

    let!(:expert_primary) do
      expert = create :expert_with_users, :with_expert_subjects, antenne: antenne_44, full_name: 'Equipe Ddfip 44'
      create :territorial_zone, zoneable: expert.antenne, zone_type: :departement, code: '44'
      expert
    end

    let!(:expert_secondary) do
      expert = create :expert_with_users, :with_expert_subjects, antenne: antenne_other, full_name: 'Equipe DDFIP 62'
      create :territorial_zone, zoneable: expert.antenne, zone_type: :departement, code: '62'
      expert
    end

    context 'with omnisearch and insee_code params' do
      subject(:request) { get :index, params: { omnisearch: 'ddfip', insee_code: '44109' }, format: :json }

      before { request }

      it 'returns experts without duplicates' do
        expert_ids = assigns(:experts).map(&:id)
        expect(expert_ids.uniq.size).to eq(expert_ids.size)
      end

      it 'includes primary expert with correct source' do
        primary = assigns(:experts).find { |e| e.id == expert_primary.id }
        expect(primary).to be_present
        expect(primary.source).to eq('primary')
      end

      it 'does not return the same expert twice' do
        expert_id_counts = assigns(:experts).map(&:id).tally
        duplicates = expert_id_counts.select { |_id, count| count > 1 }
        expect(duplicates).to be_empty
      end
    end

    context 'with omnisearch only' do
      subject(:request) { get :index, params: { omnisearch: 'ddfip' }, format: :json }

      before { request }

      it 'returns experts without duplicates' do
        expert_ids = assigns(:experts).map(&:id)
        expect(expert_ids.uniq.size).to eq(expert_ids.size)
      end
    end
  end
end
