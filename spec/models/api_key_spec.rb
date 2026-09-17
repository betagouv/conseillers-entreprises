require 'rails_helper'

RSpec.describe ApiKey do
  describe 'scopes' do
    describe 'active' do
      subject { described_class.active }

      let!(:active_key) { create :api_key, valid_until: described_class::LIFETIME.since }
      let!(:revoked_key) { create :api_key, valid_until: 1.month.ago }

      it { is_expected.to contain_exactly(active_key) }
    end
  end

  describe 'validations' do
    describe 'scopes' do
      subject(:api_key) { build :api_key, scopes: scopes }

      context 'with a known scope' do
        let(:scopes) { [described_class::QUALIFICATION] }

        it { is_expected.to be_valid }
      end

      context 'with an unknown scope' do
        let(:scopes) { ['unknown'] }

        it { is_expected.not_to be_valid }

        it 'adds an inclusion error on scopes' do
          api_key.valid?
          expect(api_key.errors[:scopes]).to include('n\'est pas inclus(e) dans la liste')
        end
      end

      context 'with no scope' do
        let(:scopes) { [] }

        it { is_expected.to be_valid }
      end
    end

    describe 'qualification scope exclusivity' do
      subject(:api_key) { build :api_key, scopes: [described_class::QUALIFICATION] }

      context 'when no other key holds the qualification scope' do
        before { create :api_key, scopes: [] }

        it { is_expected.to be_valid }
      end

      context 'when another key already holds the qualification scope' do
        before { create :api_key, scopes: [described_class::QUALIFICATION] }

        it { is_expected.not_to be_valid }

        it 'adds a taken error on scopes' do
          api_key.valid?
          expect(api_key.errors[:scopes]).to include('n’est pas disponible')
        end
      end

      context 'when the holding key is updated' do
        subject(:api_key) { create :api_key, scopes: [described_class::QUALIFICATION] }

        it 'does not conflict with itself' do
          expect(api_key.update(valid_until: described_class::LIFETIME.since)).to be true
        end
      end
    end
  end

  describe 'instance_methods' do
    describe 'has_scope?' do
      subject(:api_key) { build :api_key, scopes: [described_class::QUALIFICATION] }

      it 'returns true when the scope is present' do
        expect(api_key.has_scope?(described_class::QUALIFICATION)).to be true
      end

      it 'returns false when the scope is absent' do
        expect(api_key.has_scope?('unknown')).to be false
      end

      it 'accepts a symbol' do
        expect(api_key.has_scope?(described_class::QUALIFICATION.to_sym)).to be true
      end
    end

    describe 'revoke' do
      subject(:api_key) { create :api_key, valid_until: described_class::LIFETIME.since }

      it 'changes key validation' do
        expect(api_key.active?).to be true
        api_key.revoke
        expect(api_key.reload.active?).to be false
      end

      # Le token en clair n’existe qu’en mémoire à la création : une clé relue en base
      # ne l’a plus, et doit rester révocable.
      it 'revokes a key loaded from the database' do
        reloaded_key = described_class.find(api_key.id)

        reloaded_key.revoke

        expect(reloaded_key.reload.active?).to be false
      end
    end

    describe 'updating a persisted key' do
      subject(:api_key) { create :api_key }

      it 'keeps the token digest untouched' do
        reloaded_key = described_class.find(api_key.id)

        expect { reloaded_key.update!(scopes: [described_class::QUALIFICATION]) }
          .not_to change { reloaded_key.reload.token_digest }
        expect(reloaded_key.has_scope?(described_class::QUALIFICATION)).to be true
      end
    end

    describe 'extend_lifetime' do
      context 'revoked_soon key' do
        subject(:api_key) { create :api_key, valid_until: 1.month.since }

        it 'changes key validation' do
          expect(api_key.active?).to be true
          expect(api_key.revoked_soon?).to be true
          api_key.extend_lifetime
          expect(api_key.reload.active?).to be true
          expect(api_key.revoked_soon?).to be false
        end
      end

      context 'revoked key' do
        subject(:api_key) { create :api_key, valid_until: 1.month.ago }

        it 'changes key validation' do
          expect(api_key.active?).to be false
          api_key.extend_lifetime
          expect(api_key.reload.active?).to be true
        end
      end

      context 'key loaded from the database' do
        subject(:api_key) { create :api_key, valid_until: 1.month.since }

        it 'changes key validation' do
          reloaded_key = described_class.find(api_key.id)

          reloaded_key.extend_lifetime

          expect(reloaded_key.reload.revoked_soon?).to be false
        end
      end
    end

    describe 'authenticate_by_token!' do
      it 'finds an active key' do
        api_key = create :api_key, valid_until: described_class::LIFETIME.since

        expect(described_class.authenticate_by_token!(api_key.token)).to eq(api_key)
      end

      it 'raises for a revoked key' do
        api_key = create :api_key, valid_until: 1.month.ago

        expect { described_class.authenticate_by_token!(api_key.token) }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
