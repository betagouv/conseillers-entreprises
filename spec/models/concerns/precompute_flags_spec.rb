require 'rails_helper'

RSpec.describe PrecomputeFlags do
  let(:landing_subject) { create :landing_subject }
  let(:siret) { '13000918600011' }
  let(:email) { 'hubertine@example.com' }

  let!(:solicitation) do
    create :solicitation, siret: siret, email: email, landing_subject: landing_subject
  end

  def precompute_result
    Solicitation.where(id: solicitation.id).precompute_flags.first
  end

  describe 'has_doublons' do
    context 'autre solicitation in_progress avec le même siret' do
      let!(:doublon) { create :solicitation, siret: siret }

      it 'détecte le doublon' do
        expect(precompute_result.has_doublons).to be true
      end
    end

    context 'autre solicitation in_progress avec le même email' do
      let!(:doublon) { create :solicitation, email: email }

      it 'détecte le doublon' do
        expect(precompute_result.has_doublons).to be true
      end
    end

    context 'autre solicitation avec un siret/email différent' do
      let!(:other) { create :solicitation, siret: '98765432100099', email: 'other@example.com' }

      it 'ne détecte pas de doublon' do
        expect(precompute_result.has_doublons).to be false
      end
    end

    context 'autre solicitation processed (pas in_progress)' do
      let!(:processed) { create :solicitation, siret: siret, status: :processed }

      it 'ne détecte pas de doublon' do
        expect(precompute_result.has_doublons).to be false
      end
    end
  end

  describe 'has_relances' do
    context 'solicitation processed récente avec même siret et même sujet' do
      let!(:relance) do
        create :solicitation,
               siret: siret,
               landing_subject: landing_subject,
               created_at: 2.weeks.ago,
               status: :processed
      end

      it 'détecte la relance' do
        expect(precompute_result.has_relances).to be true
      end
    end

    context 'solicitation processed récente avec même email et même sujet' do
      let!(:relance) do
        create :solicitation,
               email: email,
               landing_subject: landing_subject,
               created_at: 2.weeks.ago,
               status: :processed
      end

      it 'détecte la relance' do
        expect(precompute_result.has_relances).to be true
      end
    end

    context 'solicitation processed trop ancienne (> 3 semaines)' do
      let!(:old) do
        create :solicitation,
               siret: siret,
               landing_subject: landing_subject,
               created_at: 6.weeks.ago,
               status: :processed
      end

      it 'ne détecte pas de relance' do
        expect(precompute_result.has_relances).to be false
      end
    end

    context 'solicitation processed récente mais sujet différent' do
      let!(:other_subject) do
        create :solicitation,
               siret: siret,
               landing_subject: create(:landing_subject),
               created_at: 2.weeks.ago,
               status: :processed
      end

      it 'ne détecte pas de relance' do
        expect(precompute_result.has_relances).to be false
      end
    end

    context 'solicitation in_progress (pas processed)' do
      let!(:not_processed) do
        create :solicitation,
               siret: siret,
               landing_subject: landing_subject,
               created_at: 2.weeks.ago
      end

      it 'ne détecte pas de relance' do
        expect(precompute_result.has_relances).to be false
      end
    end
  end

  describe 'has_similar_abandonned' do
    context 'moins de 4 solicitations canceled avec même email' do
      before do
        3.times { create :solicitation, email: email, status: :canceled }
      end

      it 'ne détecte pas les abandons' do
        expect(precompute_result.has_similar_abandonned).to be false
      end
    end

    context '4 solicitations canceled ou plus avec même email' do
      before do
        4.times { create :solicitation, email: email, status: :canceled }
      end

      it 'détecte les abandons' do
        expect(precompute_result.has_similar_abandonned).to be true
      end
    end

    context '4 solicitations canceled avec même siret' do
      before do
        4.times { create :solicitation, siret: siret, status: :canceled }
      end

      it 'détecte les abandons' do
        expect(precompute_result.has_similar_abandonned).to be true
      end
    end

    context 'solicitations canceled mais siret/email différent' do
      before do
        4.times { create :solicitation, siret: '98765432100099', email: 'other@example.com', status: :canceled }
      end

      it 'ne détecte pas les abandons' do
        expect(precompute_result.has_similar_abandonned).to be false
      end
    end
  end

  describe 'collection vide' do
    it 'ne lève pas d erreur' do
      expect { Solicitation.none.precompute_flags }.not_to raise_error
    end
  end
end
