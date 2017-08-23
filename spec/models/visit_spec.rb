# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Visit, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :advisor
      is_expected.to belong_to :visitee
      is_expected.to belong_to :facility
      is_expected.to have_one :diagnosis
      is_expected.to validate_presence_of :advisor
      is_expected.to validate_presence_of :facility
    end
  end

  describe 'scopes' do
    describe 'of_advisor' do
      subject { Visit.of_advisor user }

      let(:user) { create :user }

      context 'visit exists' do
        it do
          visit = create :visit, advisor: user
          is_expected.to eq [visit]
        end
      end

      context 'visit does not exist' do
        it do
          create :visit
          is_expected.to be_empty
        end
      end
    end

    describe 'of_facility' do
      subject { Visit.of_facility facility }

      let(:facility) { create :facility }

      context 'visit exists' do
        it do
          visit = create :visit, facility: facility
          is_expected.to eq [visit]
        end
      end

      context 'visit does not exist' do
        it do
          create :visit
          is_expected.to be_empty
        end
      end
    end

    describe 'of_siret' do
      subject { Visit.of_siret facility.siret }

      let(:facility) { create :facility, siret: '44622002200229' }

      context 'visit exists' do
        it do
          visit = create :visit, facility: facility
          is_expected.to eq [visit]
        end
      end

      context 'visit does not exist' do
        it do
          create :visit
          is_expected.to be_empty
        end
      end
    end

    describe 'with_completed_diagnosis' do
      subject { Visit.with_completed_diagnosis }

      let(:visit) { create :visit, diagnosis: diagnosis }

      context 'visit exists' do
        let(:diagnosis) { create :diagnosis, step: 5 }

        it { is_expected.to eq [visit] }
      end

      context 'visit does not exist' do
        let(:diagnosis) { create :diagnosis, step: 2 }

        it { is_expected.to be_empty }
      end
    end
  end

  describe 'to_s' do
    it do
      facility = create :facility
      visit = create :visit, facility: facility
      expect(visit.to_s).to include facility.company.name
    end
  end

  describe 'happened_at_localized' do
    it do
      visit = create :visit, happened_at: Date.new(2017, 7, 1)
      expect(visit.happened_at_localized).to eq '01/07/2017'
    end
  end

  describe 'company_name' do
    it do
      name = 'Octo'
      company = create :company, name: name
      facility = create :facility, company: company
      visit = create :visit, facility: facility
      expect(visit.company_name).to eq name
    end
  end
end
