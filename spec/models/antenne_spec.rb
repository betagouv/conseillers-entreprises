require 'rails_helper'

RSpec.describe Antenne, type: :model do
  describe 'name code uniqueness' do
    subject { build :antenne, name: name }

    let(:name) { 'Nice Company Name' }

    context 'unique name' do
      it { is_expected.to be_valid }
    end

    context 'reused name' do
      before { create :antenne, name: name }

      it { is_expected.not_to be_valid }
    end
  end
end
