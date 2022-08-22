# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiKey, type: :model do
  describe 'scopes' do
    describe 'active' do
      subject { described_class.active }

      let!(:active_key) { create :api_key, valid_until: ApiKey::LIFETIME.since }
      let!(:revoked_key) { create :api_key, valid_until: 1.month.ago }

      it { is_expected.to match_array([active_key]) }
    end
  end

  describe 'instance_methods' do
    describe 'revoke' do
      subject(:api_key) { create :api_key, valid_until: ApiKey::LIFETIME.since }

      it 'changes key validation' do
        expect(api_key.active?).to be true
        api_key.revoke
        expect(api_key.reload.active?).to be false
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
    end
  end
end
