# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Institution, type: :model do
  it do
    is_expected.to have_many :experts
    is_expected.to validate_presence_of :name
  end

  describe 'to_s' do
    it do
      institution = create :institution, name: 'Direccte'
      expect(institution.to_s).to eq 'Direccte'
    end
  end

  describe 'compute_slug' do
    let(:institution) { build :institution, name: "My Institution" }

    context 'manual call' do
      before { institution.compute_slug }

      it { expect(institution.slug).to eq 'my_institution' }
    end

    context 'before_validation hook' do
      before { institution.save }

      it do
        expect(institution.slug).to eq 'my_institution'
        expect(institution).to be_valid
      end
    end
  end
end
