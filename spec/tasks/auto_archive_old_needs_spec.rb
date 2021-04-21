require 'rails_helper'

describe 'auto_archive_old_matches', type: :task do
  subject { described_class }

  let(:date1) { 61.days }
  let(:need_taking_care) { create :need }
  let!(:match_need_taking_care) { create :match, status: :taking_care, need: need_taking_care }
  let!(:match_quo_need_taking_care) { create :match, status: :quo, need: need_taking_care }
  let!(:need_quo) { create :need_with_matches }
  let!(:match_need_quo) { create :match, status: :quo, need: need_quo }

  context 'When matches are to old, archives them automatically' do
    # Mis en relation de plus de 60 jours avec besoin pris en charge par un autre référent : OK
    # Mis en relation de plus de 60 jours avec besoin non pris en charge par un autre référent : KO
    before do
      travel date1 do
        task.invoke
        match_quo_need_taking_care.reload
        match_need_quo.reload
      end
    end

    it 'succeeds' do
      expect(match_quo_need_taking_care.is_archived).to eq(true)
      expect(match_need_quo.is_archived).to eq(false)
    end
  end

  context 'When matches are not to old, not archives them automatically' do
    # Mis en relation de moins de 60 jours avec besoin pris en charge par un autre référent : OK
    # Mis en relation de moins de 60 jours avec besoin non pris en charge par un autre référent : KO
    before do
      task.invoke
      need_taking_care.reload
      need_quo.reload
    end

    it 'succeeds' do
      expect(match_quo_need_taking_care.is_archived).to eq(false)
      expect(match_need_quo.is_archived).to eq(false)
    end
  end
end
