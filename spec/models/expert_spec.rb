# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Expert, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :institution
      is_expected.to have_many(:assistances_experts).dependent(:destroy)
      is_expected.to have_many :assistances
      is_expected.to validate_presence_of(:last_name)
      is_expected.to validate_presence_of(:role)
      is_expected.to validate_presence_of(:institution)
      is_expected.to validate_presence_of(:email)
    end
  end

  describe 'full_name' do
    let(:expert) { build :expert, first_name: 'Ivan', last_name: 'Collombet' }

    it { expect(expert.full_name).to eq 'Ivan Collombet' }
  end

  describe 'to_s' do
    let(:expert) { build :expert, first_name: 'Ivan', last_name: 'Collombet' }

    it { expect(expert.to_s).to eq 'Ivan Collombet' }
  end
end
