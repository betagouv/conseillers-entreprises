# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solicitation, type: :model do
  describe 'associations' do
    it { is_expected.to have_many :diagnoses }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :landing_slug }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :full_name }
    it { is_expected.to validate_presence_of :phone_number }
    it { is_expected.to validate_presence_of :email }
  end

  describe 'custom validations' do
    describe 'validate_landing_options_on_create' do
      subject(:solicitation) { build :solicitation, landing: landing, landing_options: options }

      before { solicitation.validate }

      context 'no option in landing' do
        let(:landing) { create :landing }
        let(:options) { [] }

        it { is_expected.to be_valid }
      end

      context 'with options in landing' do
        let(:landing) { create :landing, :with_options }

        context 'with a chosen option' do
          let(:options) { [landing.landing_options.first] }

          it { is_expected.to be_valid }
        end

        context 'with no chosen option' do
          let(:options) { [] }

          it { is_expected.not_to be_valid }
          it { expect(solicitation.errors.details).to eq({ landing_options: [{ error: :blank }] }) }
        end
      end
    end
  end
end
